local Main = require(script.Main)
local Factory = require(script.Factory)

--------------------

export type BlackFerrariBox = Main.BlackFerrariBox
export type Kind = Factory.Kind

--------------------

return {
    Main = Main,  
    Factory = Factory,
}