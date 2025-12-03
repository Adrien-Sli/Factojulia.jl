using Bonito
using Bonito: onjs, onload, Button
# Create a reactive counter app
app = App() do session
    count = Observable(0)
    
    button = Button("Click me!", onclick=js"""(e)=> {
        count += 1
    }""")
    
    return DOM.div(button, DOM.h1("Count: ", count))
end