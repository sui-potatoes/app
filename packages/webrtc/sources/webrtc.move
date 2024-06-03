/// Module: ping
module webrtc::webrtc {
    use std::string::String;

    /// The message sent by one address to another to establish a WebRTC
    /// connection.
    public struct Offer has key {
        id: UID,
        from: address,
        sdp: vector<u8>,
    }

    /// The message sent by the recipient of an Offer to accept the offer and
    /// establish a WebRTC connection.
    public struct Answer has key {
        id: UID,
        from: address,
        sdp: vector<u8>
    }

    /// An event announcing the person's presence in the network.
    public struct Ping has copy, drop { name: String }

    /// Send a `Ping` message to the network.
    public fun ping(name: String) {
        sui::event::emit(Ping { name })
    }

    /// Send the `Offer` to the recipient (`to`).
    public fun send_offer(sdp: vector<u8>, to: address, ctx: &mut TxContext) {
        transfer::transfer(Offer {
            id: object::new(ctx),
            from: ctx.sender(),
            sdp,
        }, to)
    }

    /// Reply to the `Offer` with an `Answer`.
    public fun reply(offer: Offer, sdp: vector<u8>, ctx: &mut TxContext) {
        let Offer { id, from: to, sdp: _ } = offer;
        object::delete(id);
        transfer::transfer(Answer {
            id: object::new(ctx),
            from: ctx.sender(),
            sdp,
        }, to);
    }

    /// Ignore the `Answer`.
    public fun ignore(answer: Answer) {
        let Answer { id, from: _, sdp: _ } = answer;
        object::delete(id);
    }
}
