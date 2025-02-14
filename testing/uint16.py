def uint16(i: int) -> bytes:
    assert i < 65536, "argument i too large for uint16"
    assert i >= 0, "argument i too small for uint16"
    ret = i.to_bytes(length=2)
    return ret
