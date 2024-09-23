// generated by codegen, do not edit
/**
 * This module provides the generated definition of `LiteralPat`.
 * INTERNAL: Do not import directly.
 */

private import codeql.rust.elements.internal.generated.Synth
private import codeql.rust.elements.internal.generated.Raw
import codeql.rust.elements.LiteralExpr
import codeql.rust.elements.internal.PatImpl::Impl as PatImpl

/**
 * INTERNAL: This module contains the fully generated definition of `LiteralPat` and should not
 * be referenced directly.
 */
module Generated {
  /**
   * A literal pattern. For example:
   * ```rust
   * match x {
   *     42 => "ok",
   *     _ => "fail",
   * }
   * ```
   * INTERNAL: Do not reference the `Generated::LiteralPat` class directly.
   * Use the subclass `LiteralPat`, where the following predicates are available.
   */
  class LiteralPat extends Synth::TLiteralPat, PatImpl::Pat {
    override string getAPrimaryQlClass() { result = "LiteralPat" }

    /**
     * Gets the literal of this literal pat, if it exists.
     */
    LiteralExpr getLiteral() {
      result =
        Synth::convertLiteralExprFromRaw(Synth::convertLiteralPatToRaw(this)
              .(Raw::LiteralPat)
              .getLiteral())
    }

    /**
     * Holds if `getLiteral()` exists.
     */
    final predicate hasLiteral() { exists(this.getLiteral()) }
  }
}
