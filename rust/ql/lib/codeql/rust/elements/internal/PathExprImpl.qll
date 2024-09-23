// generated by codegen, remove this comment if you wish to edit this file
/**
 * This module provides a hand-modifiable wrapper around the generated class `PathExpr`.
 *
 * INTERNAL: Do not use.
 */

private import codeql.rust.elements.internal.generated.PathExpr

/**
 * INTERNAL: This module contains the customizable definition of `PathExpr` and should not
 * be referenced directly.
 */
module Impl {
  /**
   * A path expression. For example:
   * ```rust
   * let x = variable;
   * let x = foo::bar;
   * let y = <T>::foo;
   * let z = <TypeRef as Trait>::foo;
   * ```
   */
  class PathExpr extends Generated::PathExpr { }
}
