function PugspeakCompileBuffer(_buffer, _offset = undefined, _size = undefined)
{
    return Pugspeak.compileGML(Pugspeak.parse(_buffer, _offset, _size));
}