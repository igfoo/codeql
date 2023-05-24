// generated by codegen/codegen.py
private import codeql.swift.generated.Synth
private import codeql.swift.generated.Raw
import codeql.swift.elements.expr.Argument
import codeql.swift.elements.expr.LiteralExpr

module Generated {
  /**
   * An instance of `#fileLiteral`, `#imageLiteral` or `#colorLiteral` expressions, which are used in playgrounds.
   */
  class ObjectLiteralExpr extends Synth::TObjectLiteralExpr, LiteralExpr {
    override string getAPrimaryQlClass() { result = "ObjectLiteralExpr" }

    /**
     * Gets the kind of this object literal expression.
     *
     * This is 0 for `#fileLiteral`, 1 for `#imageLiteral` and 2 for `#colorLiteral`.
     */
    int getKind() {
      result = Synth::convertObjectLiteralExprToRaw(this).(Raw::ObjectLiteralExpr).getKind()
    }

    /**
     * Gets the `index`th argument of this object literal expression (0-based).
     *
     * This includes nodes from the "hidden" AST. It can be overridden in subclasses to change the
     * behavior of both the `Immediate` and non-`Immediate` versions.
     */
    Argument getImmediateArgument(int index) {
      result =
        Synth::convertArgumentFromRaw(Synth::convertObjectLiteralExprToRaw(this)
              .(Raw::ObjectLiteralExpr)
              .getArgument(index))
    }

    /**
     * Gets the `index`th argument of this object literal expression (0-based).
     */
    final Argument getArgument(int index) {
      exists(Argument immediate |
        immediate = this.getImmediateArgument(index) and
        if exists(this.getResolveStep()) then result = immediate else result = immediate.resolve()
      )
    }

    /**
     * Gets any of the arguments of this object literal expression.
     */
    final Argument getAnArgument() { result = this.getArgument(_) }

    /**
     * Gets the number of arguments of this object literal expression.
     */
    final int getNumberOfArguments() { result = count(int i | exists(this.getArgument(i))) }
  }
}
