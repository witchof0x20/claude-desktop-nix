use napi_derive::napi;

#[napi]
pub struct KeyboardKey {}

#[napi]
pub fn init() -> napi::Result<KeyboardKey> {
    Ok(KeyboardKey { })
}
