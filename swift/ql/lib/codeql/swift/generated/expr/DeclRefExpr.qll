// generated by codegen/codegen.py
private import codeql.swift.generated.Synth
private import codeql.swift.generated.Raw
import codeql.swift.elements.decl.Decl
import codeql.swift.elements.expr.Expr
import codeql.swift.elements.type.Type

module Generated {
  class DeclRefExpr extends Synth::TDeclRefExpr, Expr {
    override string getAPrimaryQlClass() { result = "DeclRefExpr" }

    /**
     * Gets the declaration of this declaration reference expression.
     *
     * This includes nodes from the "hidden" AST. It can be overridden in subclasses to change the
     * behavior of both the `Immediate` and non-`Immediate` versions.
     */
    Decl getImmediateDecl() {
      result =
        Synth::convertDeclFromRaw(Synth::convertDeclRefExprToRaw(this).(Raw::DeclRefExpr).getDecl())
    }

    /**
     * Gets the declaration of this declaration reference expression.
     */
    final Decl getDecl() {
      exists(Decl immediate |
        immediate = this.getImmediateDecl() and
        if exists(this.getResolveStep()) then result = immediate else result = immediate.resolve()
      )
    }

    /**
     * Gets the `index`th replacement type of this declaration reference expression (0-based).
     *
     * This includes nodes from the "hidden" AST. It can be overridden in subclasses to change the
     * behavior of both the `Immediate` and non-`Immediate` versions.
     */
    Type getImmediateReplacementType(int index) {
      result =
        Synth::convertTypeFromRaw(Synth::convertDeclRefExprToRaw(this)
              .(Raw::DeclRefExpr)
              .getReplacementType(index))
    }

    /**
     * Gets the `index`th replacement type of this declaration reference expression (0-based).
     */
    final Type getReplacementType(int index) {
      exists(Type immediate |
        immediate = this.getImmediateReplacementType(index) and
        if exists(this.getResolveStep()) then result = immediate else result = immediate.resolve()
      )
    }

    /**
     * Gets any of the replacement types of this declaration reference expression.
     */
    final Type getAReplacementType() { result = this.getReplacementType(_) }

    /**
     * Gets the number of replacement types of this declaration reference expression.
     */
    final int getNumberOfReplacementTypes() {
      result = count(int i | exists(this.getReplacementType(i)))
    }

    /**
     * Holds if this declaration reference expression has direct to storage semantics.
     */
    predicate hasDirectToStorageSemantics() {
      Synth::convertDeclRefExprToRaw(this).(Raw::DeclRefExpr).hasDirectToStorageSemantics()
    }

    /**
     * Holds if this declaration reference expression has direct to implementation semantics.
     */
    predicate hasDirectToImplementationSemantics() {
      Synth::convertDeclRefExprToRaw(this).(Raw::DeclRefExpr).hasDirectToImplementationSemantics()
    }

    /**
     * Holds if this declaration reference expression has ordinary semantics.
     */
    predicate hasOrdinarySemantics() {
      Synth::convertDeclRefExprToRaw(this).(Raw::DeclRefExpr).hasOrdinarySemantics()
    }

    /**
     * Holds if this declaration reference expression has distributed thunk semantics.
     */
    predicate hasDistributedThunkSemantics() {
      Synth::convertDeclRefExprToRaw(this).(Raw::DeclRefExpr).hasDistributedThunkSemantics()
    }
  }
}
