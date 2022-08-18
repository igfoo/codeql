// generated by codegen/codegen.py
private import codeql.swift.generated.Synth
private import codeql.swift.generated.Raw
import codeql.swift.elements.AstNode
import codeql.swift.elements.stmt.Stmt

class BraceStmtBase extends Synth::TBraceStmt, Stmt {
  override string getAPrimaryQlClass() { result = "BraceStmt" }

  AstNode getImmediateElement(int index) {
    result =
      Synth::convertAstNodeFromRaw(Synth::convertBraceStmtToRaw(this)
            .(Raw::BraceStmt)
            .getElement(index))
  }

  final AstNode getElement(int index) { result = getImmediateElement(index).resolve() }

  final AstNode getAnElement() { result = getElement(_) }

  final int getNumberOfElements() { result = count(getAnElement()) }
}
