import Carbon

let currentSource = TISCopyCurrentKeyboardInputSource().takeRetainedValue()
let currentID = unsafeBitCast(TISGetInputSourceProperty(currentSource, kTISPropertyInputSourceID), to: CFString.self) as String

let targetID: String
if currentID.contains("Hebrew") {
    targetID = "com.apple.keylayout.ABC"
} else {
    targetID = "com.apple.keylayout.Hebrew"
}

let filter = [kTISPropertyInputSourceID: targetID] as CFDictionary
if let sources = TISCreateInputSourceList(filter, false)?.takeRetainedValue() as? [TISInputSource],
   let source = sources.first {
    TISSelectInputSource(source)
}
