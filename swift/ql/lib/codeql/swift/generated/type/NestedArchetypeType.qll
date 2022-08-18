// generated by codegen/codegen.py
private import codeql.swift.generated.Synth
private import codeql.swift.generated.Raw
import codeql.swift.elements.type.ArchetypeType
import codeql.swift.elements.decl.AssociatedTypeDecl

class NestedArchetypeTypeBase extends Synth::TNestedArchetypeType, ArchetypeType {
  override string getAPrimaryQlClass() { result = "NestedArchetypeType" }

  ArchetypeType getImmediateParent() {
    result =
      Synth::convertArchetypeTypeFromRaw(Synth::convertNestedArchetypeTypeToRaw(this)
            .(Raw::NestedArchetypeType)
            .getParent())
  }

  final ArchetypeType getParent() { result = getImmediateParent().resolve() }

  AssociatedTypeDecl getImmediateAssociatedTypeDeclaration() {
    result =
      Synth::convertAssociatedTypeDeclFromRaw(Synth::convertNestedArchetypeTypeToRaw(this)
            .(Raw::NestedArchetypeType)
            .getAssociatedTypeDeclaration())
  }

  final AssociatedTypeDecl getAssociatedTypeDeclaration() {
    result = getImmediateAssociatedTypeDeclaration().resolve()
  }
}
