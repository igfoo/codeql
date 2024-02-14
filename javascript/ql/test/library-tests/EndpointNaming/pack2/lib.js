class AmbiguousClass {
    instanceMethod(foo) {} // $ method=(pack2).lib.LibClass.prototype.instanceMethod
} // $ class=(pack2).lib.LibClass instance=(pack2).lib.LibClass.prototype

export default AmbiguousClass; // $ alias=(pack2).lib.default==(pack2).lib.LibClass
export { AmbiguousClass as LibClass }

AmbiguousClass.foo = function() {} // $ method=(pack2).lib.LibClass.foo alias=(pack2).lib.default.foo==(pack2).lib.LibClass.foo
