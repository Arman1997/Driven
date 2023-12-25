enum SomeEnum {}

extension SomeEnum {
    class A {
        
        struct SomeStruct {}
    }
}

extension SomeEnum {
    class B: A {
        
        func foo() {
            SomeStruct()
        }
    }
}
