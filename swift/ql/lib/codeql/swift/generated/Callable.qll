// generated by codegen/codegen.py
private import codeql.swift.generated.Synth
private import codeql.swift.generated.Raw
import codeql.swift.elements.stmt.BraceStmt
import codeql.swift.elements.decl.CapturedDecl
import codeql.swift.elements.Element
import codeql.swift.elements.decl.ParamDecl

module Generated {
  class Callable extends Synth::TCallable, Element {
    /**
     * Gets the name of this callable, if it exists.
     */
    string getName() { result = Synth::convertCallableToRaw(this).(Raw::Callable).getName() }

    /**
     * Holds if `getName()` exists.
     */
    final predicate hasName() { exists(this.getName()) }

    /**
     * Gets the self parameter of this callable, if it exists.
     *
     * This includes nodes from the "hidden" AST. It can be overridden in subclasses to change the
     * behavior of both the `Immediate` and non-`Immediate` versions.
     */
    ParamDecl getImmediateSelfParam() {
      result =
        Synth::convertParamDeclFromRaw(Synth::convertCallableToRaw(this)
              .(Raw::Callable)
              .getSelfParam())
    }

    /**
     * Gets the self parameter of this callable, if it exists.
     */
    final ParamDecl getSelfParam() {
      exists(ParamDecl immediate |
        immediate = this.getImmediateSelfParam() and
        if exists(this.getResolveStep()) then result = immediate else result = immediate.resolve()
      )
    }

    /**
     * Holds if `getSelfParam()` exists.
     */
    final predicate hasSelfParam() { exists(this.getSelfParam()) }

    /**
     * Gets the `index`th parameter of this callable (0-based).
     *
     * This includes nodes from the "hidden" AST. It can be overridden in subclasses to change the
     * behavior of both the `Immediate` and non-`Immediate` versions.
     */
    ParamDecl getImmediateParam(int index) {
      result =
        Synth::convertParamDeclFromRaw(Synth::convertCallableToRaw(this)
              .(Raw::Callable)
              .getParam(index))
    }

    /**
     * Gets the `index`th parameter of this callable (0-based).
     */
    final ParamDecl getParam(int index) {
      exists(ParamDecl immediate |
        immediate = this.getImmediateParam(index) and
        if exists(this.getResolveStep()) then result = immediate else result = immediate.resolve()
      )
    }

    /**
     * Gets any of the parameters of this callable.
     */
    final ParamDecl getAParam() { result = this.getParam(_) }

    /**
     * Gets the number of parameters of this callable.
     */
    final int getNumberOfParams() { result = count(int i | exists(this.getParam(i))) }

    /**
     * Gets the body of this callable, if it exists.
     *
     * This includes nodes from the "hidden" AST. It can be overridden in subclasses to change the
     * behavior of both the `Immediate` and non-`Immediate` versions.
     */
    BraceStmt getImmediateBody() {
      result =
        Synth::convertBraceStmtFromRaw(Synth::convertCallableToRaw(this).(Raw::Callable).getBody())
    }

    /**
     * Gets the body of this callable, if it exists.
     *
     * The body is absent within protocol declarations.
     */
    final BraceStmt getBody() {
      exists(BraceStmt immediate |
        immediate = this.getImmediateBody() and
        if exists(this.getResolveStep()) then result = immediate else result = immediate.resolve()
      )
    }

    /**
     * Holds if `getBody()` exists.
     */
    final predicate hasBody() { exists(this.getBody()) }

    /**
     * Gets the `index`th capture of this callable (0-based).
     *
     * This includes nodes from the "hidden" AST. It can be overridden in subclasses to change the
     * behavior of both the `Immediate` and non-`Immediate` versions.
     */
    CapturedDecl getImmediateCapture(int index) {
      result =
        Synth::convertCapturedDeclFromRaw(Synth::convertCallableToRaw(this)
              .(Raw::Callable)
              .getCapture(index))
    }

    /**
     * Gets the `index`th capture of this callable (0-based).
     */
    final CapturedDecl getCapture(int index) {
      exists(CapturedDecl immediate |
        immediate = this.getImmediateCapture(index) and
        if exists(this.getResolveStep()) then result = immediate else result = immediate.resolve()
      )
    }

    /**
     * Gets any of the captures of this callable.
     */
    final CapturedDecl getACapture() { result = this.getCapture(_) }

    /**
     * Gets the number of captures of this callable.
     */
    final int getNumberOfCaptures() { result = count(int i | exists(this.getCapture(i))) }
  }
}
