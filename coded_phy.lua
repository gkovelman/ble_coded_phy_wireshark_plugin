-- declare the protocol
coded_phy_proto = Proto("btle_coded_phy", "BLE Coded PHY (lua)")

-- declare the value strings
local pdu_type_vals = {
    [0x00] = "ADV_IND" ,
    [0x01] = "ADV_DIRECT_IND" ,
    [0x02] = "ADV_NONCONN_IND" ,
    [0x03] = "SCAN_REQ" ,
    [0x04] = "SCAN_RSP" ,
    [0x05] = "CONNECT_REQ" ,
    [0x06] = "ADV_SCAN_IND" ,
    [0x07] = "AUX_ADV_IND" ,
}

local ADV_EXT_IND = 0x07
local AUX_ADV_IND = 0x07


-- declare the fields
local f_access_address = ProtoField.uint32("btle_coded_phy.access_address", "Access Address", base.HEX)
local hf_length = ProtoField.uint8("btle_coded_phy.length", "Length", base.DEC)

local f_advertising_header = ProtoField.string("btle_coded_phy.advertising_header", "Advertising header")

local hf_advertising_header = ProtoField.uint16("btle_coded_phy.advertising_header", "Packet Header", base.HEX)
local hf_advertising_header_pdu_type = ProtoField.uint8("btle_coded_phy.advertising_header.pdu_type", "PDU Type", base.HEX)
local hf_advertising_header_rfu_1 = ProtoField.uint8("btle_coded_phy.advertising_header.rfu.1", "RFU", base.DEC)
local hf_advertising_header_ch_sel = ProtoField.uint8("btle_coded_phy.advertising_header.ch_sel", "Channel Selection Algorithm", base.HEX)
local hf_advertising_header_randomized_tx = ProtoField.uint8("btle_coded_phy.advertising_header.randomized_tx", "Tx Address", base.HEX)
local hf_advertising_header_randomized_rx = ProtoField.uint8("btle_coded_phy.advertising_header.randomized_rx", "Rx Address", base.HEX)
local hf_advertising_header_reserved = ProtoField.uint8("btle_coded_phy.advertising_header.reserved", "Reserved", base.HEX)
local hf_advertising_header_length = ProtoField.uint8("btle_coded_phy.advertising_header.length", "Length", base.DEC)

local hf_advertising_extended_header = ProtoField.uint8("btle_coded_phy.advertising_header.extended_header", "Extended header", base.HEX)
local hf_advertising_extended_header_length = ProtoField.uint8("btle_coded_phy.advertising_header.extended_header_length", "Extended header length", base.DEC)
local hf_advertising_extended_header_advmode = ProtoField.uint8("btle_coded_phy.advertising_header.extended_header_advmode", "AdvMode", base.HEX)

local hf_advertising_extended_header_payload = ProtoField.bytes("btle_coded_phy.advertising_header.extended_header_payload", "Extended header payload")
local hf_advertising_extended_header_payload_flags = ProtoField.uint8("btle_coded_phy.advertising_header.extended_header_payload.flags", "Extended header flags", base.HEX)
local hf_advertising_extended_header_payload_adva = ProtoField.ether("btle_coded_phy.advertising_header.extended_header_payload.adva", "AdvA")
local hf_advertising_extended_header_payload_targeta = ProtoField.ether("btle_coded_phy.advertising_header.extended_header_payload.targeta", "TargetA")
local hf_advertising_extended_header_payload_cteinfo = ProtoField.uint8("btle_coded_phy.advertising_header.extended_header_payload.cteinfo", "CTEInfo", base.HEX)
local hf_advertising_extended_header_payload_adi = ProtoField.uint16("btle_coded_phy.advertising_header.extended_header_payload.adi", "ADI", base.HEX)
local hf_advertising_extended_header_payload_auxptr = ProtoField.bytes("btle_coded_phy.advertising_header.extended_header_payload.auxptr", "AuxPtr")
local hf_advertising_extended_header_payload_syncinfo = ProtoField.bytes("btle_coded_phy.advertising_header.extended_header_payload.syncinfo", "SyncInfo")
local hf_advertising_extended_header_payload_txpower = ProtoField.uint8("btle_coded_phy.advertising_header.extended_header_payload.txpower", "TxPower", base.DEC)
local hf_advertising_extended_header_payload_rfu = ProtoField.uint8("btle_coded_phy.advertising_header.extended_header_payload.rfu", "RFU", base.DEC)

local hf_advertising_extended_header_flags = ProtoField.uint8("btle_coded_phy.advertising_header.extended_header_flags", "Extended header flags", base.HEX)

local hf_advertising_address = ProtoField.ether("btle_coded_phy.advertising_address", "Advertising Address")


coded_phy_proto.fields = { 
    f_access_address, 
    hf_advertising_header, 
        hf_advertising_header_pdu_type, hf_advertising_header_rfu_1, hf_advertising_header_ch_sel, hf_advertising_header_randomized_tx, hf_advertising_header_randomized_rx,
        hf_advertising_header_reserved, hf_advertising_header_length, 
    hf_advertising_extended_header, 
        hf_advertising_extended_header_length, hf_advertising_extended_header_advmode, 

    hf_advertising_extended_header_payload, 
        hf_advertising_extended_header_payload_flags, hf_advertising_extended_header_payload_adva, hf_advertising_extended_header_payload_targeta, 
        hf_advertising_extended_header_payload_cteinfo, hf_advertising_extended_header_payload_adi,
        hf_advertising_extended_header_payload_auxptr, hf_advertising_extended_header_payload_syncinfo, hf_advertising_extended_header_payload_txpower, hf_advertising_extended_header_payload_rfu,

    hf_advertising_address
}

function coded_phy_proto.dissector(buffer, pinfo, tree)
    -- To not repeat some dissection, call the original dissector
    Dissector.get("btle_rf"):call(buffer, pinfo, tree)

    local crc_init = 0x555555

    -- Set the protocol column
    pinfo.cols['protocol'] = "BLE Coded PHY"

    local offset = 0

    offset = offset + 2 + 2 + 4 + 2
    
    -- create the BTLE Coded phy protocol tree item
    local t_btle_coded_phy = tree:add(coded_phy_proto, buffer(offset))

    -- Add the header tree item and populate it
    local access_address = tostring(buffer(offset, 4):bytes())
    local t_access_address = t_btle_coded_phy:add_le(f_access_address, buffer(offset, 4))
    offset = offset + 4

    local t_advertising_header_item = t_btle_coded_phy:add(hf_advertising_header, buffer(offset, 2))

    local pdu_type = bit.band(buffer(offset, 1):uint(), 0x0F)
    -- The added plugin only handles extended advertisement, so ignore others (and let the original dissector do its job)
    if ADV_EXT_IND ~= 0x07 then
        t_btle_coded_phy:append_text(" (Not extended advertisement)")
        return
    end

    local ch_sel = bit.rshift(bit.band(buffer(offset, 1):uint(), 0x20), 5)
    local random_public = bit.band(buffer(offset, 1):uint(), 0x40)

    local header_string = string.format( " (PDU Type: %s, ChSel: %s, TxAdd: %s", 
        pdu_type_vals[pdu_type],
        (bit.band(ch_sel, 0x01) and "#1" or "#2"),
        ((random_public ~= 0x00) and "Random" or "Public"))
    t_advertising_header_item:append_text(header_string)

    t_advertising_header_item:add(hf_advertising_header_pdu_type, buffer(offset, 1))
    t_advertising_header_item:add(hf_advertising_header_rfu_1, buffer(offset, 1))
    t_advertising_header_item:add(hf_advertising_header_ch_sel, buffer(offset, 1))
    t_advertising_header_item:add(hf_advertising_header_randomized_tx, buffer(offset, 1))
    -- pdu_type == 0x07
    t_advertising_header_item:add(hf_advertising_header_randomized_rx, buffer(offset, 1))
    t_advertising_header_item:append_text(", RxAdd : ?)")
    offset = offset + 1

    t_advertising_header_item:add(hf_advertising_header_length, buffer(offset, 1))
    local hf_length = buffer(offset, 1):uint()
    local item = t_btle_coded_phy:add(hf_length, buffer(offset, 1))
    item:set_hidden()

    offset = offset + 1

    local t_advertising_extended_header = t_advertising_header_item:add(hf_advertising_extended_header, buffer(offset, 1))
    local extended_header_length = bit.band(buffer(offset, 1):uint(), 0x3F)
    local AdvMode = bit.rshift(bit.band(buffer(offset, 1):uint(), 0xC0), 6)

    local extended_header_string = string.format( " (Length: %s, AdvMode: %x)",  tostring(extended_header_length), AdvMode)
    t_advertising_extended_header:append_text(extended_header_string)

    t_advertising_extended_header:add(hf_advertising_extended_header_length, buffer(offset, 1))
    t_advertising_extended_header:add(hf_advertising_extended_header_advmode, buffer(offset, 1))

    offset = offset + 1

    local t_advertising_extended_header_payload = t_advertising_header_item:add(hf_advertising_extended_header_payload, buffer(offset, extended_header_length))

    t_advertising_extended_header_payload:add(hf_advertising_extended_header_payload_flags, buffer(offset, 1))
    local advertising_extended_header_payload_flags = buffer(offset, 1):uint()
    offset = offset + 1

    if bit.band(advertising_extended_header_payload_flags, 0x01) ~= 0 then
        t_advertising_extended_header_payload:add(hf_advertising_extended_header_payload_adva, buffer(offset, 6))
        offset = offset + 6
    end
    if bit.band(advertising_extended_header_payload_flags, 0x02) ~= 0 then
        t_advertising_extended_header_payload:add(hf_advertising_extended_header_payload_targeta, buffer(offset, 6))
        offset = offset + 6
    end
    if bit.band(advertising_extended_header_payload_flags, 0x04) ~= 0 then
        t_advertising_extended_header_payload:add(hf_advertising_extended_header_payload_cteinfo, buffer(offset, 1))
        offset = offset + 1
    end
    if bit.band(advertising_extended_header_payload_flags, 0x08) ~= 0 then
        local t_advertising_extended_header_payload_adi = t_advertising_extended_header_payload:add(hf_advertising_extended_header_payload_adi, buffer(offset, 2))
        local adi = buffer(offset, 2):uint()
        t_advertising_extended_header_payload_adi:append_text(string.format( " (DID: %d, SID: %d)", bit.band(adi, 0x7F), bit.rshift(bit.band(adi, 0xF000), 12)))
        offset = offset + 2
    end
    if bit.band(advertising_extended_header_payload_flags, 0x10) ~= 0 then
        local t_advertising_extended_header_payload_auxptr = buffer(offset, 3)
        local offset_units = bit.rshift(bit.band(t_advertising_extended_header_payload_auxptr(0, 1):uint(), 0x80), 7)
        local CA = bit.rshift(bit.band(t_advertising_extended_header_payload_auxptr(0, 1):uint(), 0x40), 6)
        local channel_index = bit.rshift(bit.band(t_advertising_extended_header_payload_auxptr(0, 1):uint(), 0x3F), 0)
        local AUX_PHY = bit.rshift(bit.band(t_advertising_extended_header_payload_auxptr(1, 2):le_uint(), 0xE000), 13)
        local AUX_offset = bit.rshift(bit.band(t_advertising_extended_header_payload_auxptr(1, 2):le_uint(), 0x1FFF), 0)
        local t_advertising_extended_header_payload_auxptr = t_advertising_extended_header_payload:add(hf_advertising_extended_header_payload_auxptr, t_advertising_extended_header_payload_auxptr)
        t_advertising_extended_header_payload_auxptr:append_text(string.format( " (ChIdx: %u, CA: %d, OffsetUnits: %d; AUX offset: %u, AUX PHY: %u)", channel_index, CA, offset_units, AUX_offset, AUX_PHY))
        offset = offset + 3
    end
    if bit.band(advertising_extended_header_payload_flags, 0x20) ~= 0 then
        t_advertising_extended_header_payload:add(hf_advertising_extended_header_payload_syncinfo, buffer(offset, 18))
        offset = offset + 18
    end
    if bit.band(advertising_extended_header_payload_flags, 0x40) ~= 0 then
        t_advertising_extended_header_payload:add(hf_advertising_extended_header_payload_txpower, buffer(offset, 1))
        offset = offset + 1
    end

end



-- local t = DissectorTable.list()

-- for _,name in ipairs(t) do
--     print(name)
-- end

-- -- load the BT table
local btle_table = DissectorTable.get("bluetooth.encap")

btle_table:add(161, coded_phy_proto)

