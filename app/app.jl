using Bonito
app = App() do
    return DOM.div(DOM.h1("hello world"), js"""console.log('hello world')""")
end