// generated by codegen/codegen.py
private import codeql.swift.generated.Synth
private import codeql.swift.generated.Raw
import codeql.swift.elements.decl.GenericTypeDecl

class TypeAliasDeclBase extends Synth::TTypeAliasDecl, GenericTypeDecl {
  override string getAPrimaryQlClass() { result = "TypeAliasDecl" }
}
