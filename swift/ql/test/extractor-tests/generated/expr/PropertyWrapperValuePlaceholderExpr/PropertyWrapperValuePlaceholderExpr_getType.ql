// generated by codegen/codegen.py, do not edit
import codeql.swift.elements
import TestUtils

from PropertyWrapperValuePlaceholderExpr x
where toBeTested(x) and not x.isUnknown()
select x, x.getType()
