/**
 * Provides classes and predicates for detecting files generated by popular module bundlers.
 */

import javascript

/**
 * Holds if `oe` looks like it was produced by [Browserify](http://browserify.org/).
 *
 * Generally, Browserify's output looks like this:
 *
 * ```javascript
 * (function e(t, n, r) {
 *   // module loader code
 * }({
 *   1: [ function(require, module, exports) {
 *          require("./dep1");
 *          require("./dep2);
 *          // ...
 *        }, { "./dep1": 2, "./dep2": 4, ... } ],
 *   2: [ function(require, module, exports) {
 *          // code for module "dep1"
 *        }, { ... } ],
 *   3: ...,
 *   4: [ function(require, module, exports) {
 *          // code for module "dep2"
 *        }, { ... } ],
 *   ...
 * }, {}, [1]);
 * ```
 */
predicate isBrowserifyBundle(ObjectExpr oe) {
  // ensure that there is at least one property
  forex(Property p | p = oe.getAProperty() |
    // and each property looks like a packed module
    isBrowserifyBundledModule(p)
  ) and
  // the whole object must be passed to the module loader function
  exists(CallExpr ce | ce.getCallee().getUnderlyingValue() instanceof Function |
    // the module loader function always has three arguments
    ce.getNumArgument() = 3 and
    // the first of which is the bundle
    ce.getArgument(0) = oe
  )
}

/**
 * Holds if `e` could be a module name in a Browserify-created bundle, that is,
 * it is either a decimal literal or a string literal.
 */
private predicate isBrowserifyModuleId(Expr e) {
  e.(NumberLiteral).getValue().regexpMatch("[0-9]+") or
  e instanceof ConstantString
}

/**
 * Holds if `p` looks like a bundled module generated by Browserify.
 */
private predicate isBrowserifyBundledModule(Property p) {
  // the key must be a module id
  isBrowserifyModuleId(p.(ValueProperty).getNameExpr()) and
  // the value must look like a bundled up module
  exists(ArrayExpr ae | ae = p.getInit() |
    // first element must be a function (known as the module factory function)
    isBrowserifyModuleFactoryFunction(ae.getElement(0)) and
    // second element must be an object literal listing dependencies
    isBrowserifyDependencyMap(ae.getElement(1))
  )
}

/**
 * Holds if `factory` looks like a Browserify-generated module factory function.
 *
 * We check that each parameter is named one of `require`, `module` or `exports`,
 * and that there is at least one of them. We also recognize `_dereq_` instead
 * of `require` to account for additional mangling by
 * [derequire](https://www.npmjs.com/package/derequire).
 *
 * Currently, Browserify always generates all three parameters, but this
 * might well change in future, so we don't rely on it
 */
private predicate isBrowserifyModuleFactoryFunction(FunctionExpr factory) {
  forex(Parameter parm | parm = factory.getAParameter() |
    parm.getName().regexpMatch("require|module|exports|_dereq_")
  )
}

/**
 * Holds if `deps` looks like a Browserify-generated dependency map for a bundled module.
 */
private predicate isBrowserifyDependencyMap(ObjectExpr deps) {
  // there may be no dependencies, hence `forall` instead of `forex`
  forall(Property dep | dep = deps.getAProperty() |
    // each key must be a string literal
    dep.(ValueProperty).getNameExpr() instanceof ConstantString and
    // and each value must be a module id
    isBrowserifyModuleId(dep.getInit())
  )
}

/**
 * Holds if `m` is a function that looks like a bundled module created
 * by Webpack.
 *
 * Parameters must be named either "module" or "exports",
 * or their name must contain the substring "webpack_require"
 * or "webpack_module_template_argument".
 */
private predicate isWebpackModule(Function m) {
  forex(Parameter parm | parm = m.getAParameter() |
    exists(string name | name = parm.getName() |
      name.regexpMatch("module|exports|.*webpack_require.*|.*webpack_module_template_argument.*|.*unused_webpack_module.*")
    )
  )
}

/**
 * Holds if `ae` looks like it was produced by [Webpack](https://webpack.github.io/).
 *
 * Generally, Webpack's output looks like this:
 *
 * ```javascript
 * (function(modules) {
 *    // module loader code
 * })([
 *   function(module, exports, __webpack_require__) {
 *     __webpack_require(1);
 *     // ...
 *   },
 *   function(module, exports) {
 *     // does not use __webpack_require
 *   },
 *   // a module reference
 *   1,
 *   // a module template instantiation
 *   [1, 2],
 *   ...
 * ]);
 * ```
 */
predicate isWebpackBundle(ArrayExpr ae) {
  // ensure that there is at least one bundled module
  isWebpackModule(ae.getAnElement().getUnderlyingValue()) and
  // furthermore, every element is either
  forall(Expr elt | elt = ae.getAnElement().getUnderlyingValue() |
    // (1) a module
    isWebpackModule(elt)
    or
    // (2) a module template instantiation
    exists(ArrayExpr inner | inner = elt |
      forex(Expr innerElt | innerElt = inner.getAnElement() | innerElt instanceof NumberLiteral)
    )
    or
    // (3) a module reference
    elt instanceof NumberLiteral
  ) and
  // the whole array must be passed to a module loader function
  exists(CallExpr ce | ce.getCallee().getUnderlyingValue() instanceof Function |
    // which is the bundle
    ce.getArgument(0) = ae
  )
}

/**
 * Holds if `object` looks like a Webpack bundle of form:
 * ```javascript
 * var __webpack_modules__ = ({
 *   "file1": ((module, __webpack__exports__, __webpack_require__) => ...)
 *   ...
 * })
 * ```
 */
predicate isWebpackNamedBundle(ObjectExpr object) {
  isWebpackModule(object.getAProperty().getInit().getUnderlyingValue()) and
  exists(VarDef def |
    def.getSource().(Expr).getUnderlyingValue() = object and
    def.getTarget().(VarRef).getName() = "__webpack_modules__"
  )
}

/**
 * Holds if `tl` is a collection of concatenated files by [atpackager](https://github.com/ariatemplates/atpackager).
 */
predicate isMultiPartBundle(TopLevel tl) {
  exists(Comment c1, Comment c2 |
    c1.getTopLevel() = tl and
    c2.getTopLevel() = tl and
    c1.getText() = "***MULTI-PART" and
    c2.getText().regexpMatch("LOGICAL-PATH:.*")
  )
}

/**
 * A comment that starts with '!'. Minifiers avoid removing such comments.
 */
class ExclamationPointComment extends Comment {
  ExclamationPointComment() { this.getLine(0).matches("!%") }
}

/**
 * Gets a comment that belongs to a run of consecutive `ExclamationPointComment`s starting with `head`.
 */
Comment getExclamationPointCommentInRun(ExclamationPointComment head) {
  exists(File f |
    exists(int n |
      head.onLines(f, n, _) and
      not exists(ExclamationPointComment d | d.onLines(f, _, n - 1))
    ) and
    (
      result = head
      or
      exists(ExclamationPointComment prev, int n |
        prev = getExclamationPointCommentInRun(head) and
        prev.onLines(f, _, n) and
        result.onLines(f, n + 1, _)
      )
    )
  )
}

/**
 * Holds if this is a bundle containing multiple licenses.
 */
predicate isMultiLicenseBundle(TopLevel tl) {
  // case: comments preserved by minifiers
  count(ExclamationPointComment head |
    head.getTopLevel() = tl and
    exists(ExclamationPointComment licenseIndicator |
      licenseIndicator = getExclamationPointCommentInRun(head) and
      licenseIndicator.getLine(_).regexpMatch("(?i).*\\b(copyright|license|\\d+\\.\\d+)\\b.*")
    )
  ) > 1
  or
  // case: ordinary block comments lines that start with a license
  count(BlockComment head |
    head.getTopLevel() = tl and
    head.getLine(_)
        .regexpMatch("(?i)[\\s*]*(@license\\b.*|The [a-z0-9-]+ License (\\([a-z0-9-]+\\))?\\s*)")
  ) > 1
}

/**
 * Holds if this is a bundle with a "bundle" directive.
 */
predicate isDirectiveBundle(TopLevel tl) { exists(BundleDirective d | d.getTopLevel() = tl) }

/**
 * Holds if toplevel `tl` contains code that looks like the output of a module bundler.
 */
predicate isBundle(TopLevel tl) {
  exists(Expr e | e.getTopLevel() = tl |
    isBrowserifyBundle(e) or
    isWebpackBundle(e) or
    isWebpackNamedBundle(e)
  )
  or
  isMultiPartBundle(tl)
  or
  isMultiLicenseBundle(tl)
  or
  isDirectiveBundle(tl)
}
