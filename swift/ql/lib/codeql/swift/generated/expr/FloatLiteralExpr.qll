// generated by codegen/codegen.py
private import codeql.swift.generated.Synth
private import codeql.swift.generated.Raw
import codeql.swift.elements.expr.NumberLiteralExpr

class FloatLiteralExprBase extends Synth::TFloatLiteralExpr, NumberLiteralExpr {
  override string getAPrimaryQlClass() { result = "FloatLiteralExpr" }

  string getStringValue() {
    result = Synth::convertFloatLiteralExprToRaw(this).(Raw::FloatLiteralExpr).getStringValue()
  }
}
