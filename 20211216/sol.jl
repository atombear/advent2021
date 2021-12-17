# This is a map between hex digits and the numbers the represent.
HEX_MAP = Dict(i => parse(Int64, i) for i in "0123456789")
for (n, c) in enumerate("ABCDEF")
    HEX_MAP[c] = 9 + n
end


# number to binary representation with padding!
function num_to_bin(num :: Int64, pad :: Int64=0) :: String
    bin :: String = ""
    if num == 0
        bin = "0"
    else
        ret :: Array{Char} = []
        while num > 0
            pushfirst!(ret, (num % 2) == 1 ? '1' : '0')
            num = div(num, 2)
        end
        bin = join(ret)
    end

    if pad > length(bin)
        return join((join('0' for _ in 1:(pad-length(bin))), bin))
    else
        return bin
    end
end


# a binary representation to a number.
function bin_to_num(bin :: String) :: Int64
    ret :: Int64 = 0
    for (n, c) in enumerate(bin)
        pow = (length(bin) - n)
        ret += (c == '1' ? 1 : 0) * (2 ^ pow)
    end
    return ret
end


# some short tests
@assert num_to_bin(1) == "1"
@assert num_to_bin(2) == "10"
@assert num_to_bin(5) == "101"
@assert num_to_bin(10) == "1010"
@assert num_to_bin(2, 4) == "0010"

@assert bin_to_num("10") == 2
@assert bin_to_num("0010") == 2
@assert bin_to_num("0") == 0
@assert bin_to_num("1") == 1
@assert bin_to_num("101") == 5
@assert bin_to_num("1010") == 10
@assert bin_to_num("001") == 1


# hex to 4digit binary.
function convert_hex(hex :: String) :: String
    ret :: Array{String} = []
    for c in hex
        push!(ret, num_to_bin(HEX_MAP[c], 4))
    end
    return join(ret)
end

@assert convert_hex("D2FE28") == "110100101111111000101000"


# A helper function to split a string at a given index.
function split_at(s :: String, idx :: Int64) :: Tuple{String, String}
    return s[1:idx], s[idx+1:end]
end


# the top level function to recursively parse a package, storing relevant information
# on the journey. Return the remainder after a packet is consumed.
function consume_packet(packets :: String, running :: Vector{Int64}, number_box :: Vector{Int64}) :: String
    # check if there is any data in the packets
    if packets == "" || !('1' in packets)
        return ""
    end

    # The first 3 bits are the packet version - store them.
    packet_version, rem = split_at(packets, 3)
    push!(running, bin_to_num(packet_version))
    # The next 3 bits are the packet type.
    packet_type, rem = split_at(rem, 3)

    # if the packet type is 4, then it is a number built out of a sequence of
    # of 4 bit binary '4digits'. incidentally, these are the leaves of the tree,
    # and where the recursion stops.
    if packet_type == "100"
        nums :: Vector{String} = []
        num, rem = split_at(rem, 5)
        push!(nums, num[2:end])
        while num[1] == '1'
            num, rem = split_at(rem, 5)
            push!(nums, num[2:end])
        end
        int_num :: Int64 = bin_to_num(join(nums))
        push!(number_box, int_num)
    else
        length_type, rem = split_at(rem, 1)
        
        if length_type == "0"
            total_len_str, rem = split_at(rem, 15)
            total_len = bin_to_num(total_len_str)
            subpackets, rem = split_at(rem, total_len)
            deez_numbers = []
            while length(subpackets) > 0
                next_number_box :: Vector{Int64} = []
                subpackets = consume_packet(subpackets, running, next_number_box)
                push!(deez_numbers, next_number_box[1])
            end
        else
            num_sub_str, rem = split_at(rem, 11)
            num_sub = bin_to_num(num_sub_str)
            deez_numbers = []
            while num_sub > 0
                next_number_box :: Vector{Int64} = []
                rem = consume_packet(rem, running, next_number_box)
                push!(deez_numbers, next_number_box[1])
                num_sub -= 1
            end
        end

        if packet_type == "000"
            res = sum(deez_numbers)
        elseif packet_type == "001"
            res = prod(deez_numbers)
        elseif packet_type == "010"
            res = minimum(deez_numbers)
        elseif packet_type == "011"
            res = maximum(deez_numbers)
        elseif packet_type == "101"
            @assert length(deez_numbers) == 2
            res = deez_numbers[1] > deez_numbers[2] ? 1 : 0
        elseif packet_type == "110"
            @assert length(deez_numbers) == 2
            res = deez_numbers[1] < deez_numbers[2] ? 1 : 0
        elseif packet_type == "111"
            @assert length(deez_numbers) == 2
            res = deez_numbers[1] == deez_numbers[2] ? 1 : 0
        end
        push!(number_box, res)
    end
    return rem
end

@assert convert_hex("8A004A801A8002F478") == "100010100000000001001010100000000001101010000000000000101111010001111000"
@assert convert_hex("38006F45291200") == "00111000000000000110111101000101001010010001001000000000"
function test1()
    hex = "D2FE28"
    for test_str in ("C200B40A82",
                     "8A004A801A8002F478",
                     "620080001611562C8802118E34",
                     "C0015000016115A2E0802F182340",
                     "A0016C880162017C3686B18A3D4780")
        bin_packets = convert_hex(test_str)
        running :: Vector{Int64} = []
        number_box :: Vector{Int64} = []
        consume_packet(bin_packets, running, number_box)
        println(sum(running))
        println(number_box)
    end
end

test1()

function test2()
    hex = "D2FE28"
    for test_str in ("C200B40A82",
                     "04005AC33890",
                     "880086C3E88112",
                     "CE00C43D881120",
                     "D8005AC2A8F0",
                     "F600BC2D8F",
                     "9C005AC2F8F0",
                     "9C0141080250320F1802104A08"
              )
        bin_packets = convert_hex(test_str)
        running :: Vector{Int64} = []
        number_box :: Vector{Int64} = []
        consume_packet(bin_packets, running, number_box)
        println(number_box)
    end
end

test2()

function problem0()
    hex = "A20D5CECBD6C061006E7801224AF251AEA06D2319904921880113A931A1402A9D83D43C9FFCC1E56FF29890E00C42984337BF22C502008C26982801009426937320124E602BC01192F4A74FD7B70692F4A74FD7B700403170400F7002DC00E7003C400B0023700082C601DF8C00D30038005AA0013F40044E7002D400D10030C008000574000AB958B4B8011074C0249769913893469A72200B42673F26A005567FCC13FE673004F003341006615421830200F4608E7142629294F92861A840118F1184C0129637C007C24B19AA2C96335400013B0C0198F716213180370AE39C7620043E0D4788B440232CB34D80260008645C86D16C401B85D0BA2D18025A00ACE7F275324137FD73428200ECDFBEFF2BDCDA70D5FE5339D95B3B6C98C1DA006772F9DC9025B057331BF7D8B65108018092599C669B4B201356763475D00480010E89709E090002130CA28C62300265C188034BA007CA58EA6FB4CDA12799FD8098021400F94A6F95E3ECC73A77359A4EFCB09CEF799A35280433D1BCCA666D5EFD6A5A389542A7DCCC010958D85EC0119EED04A73F69703669466A048C01E14FFEFD229ADD052466ED37BD8B4E1D10074B3FF8CF2BBE0094D56D7E38CADA0FA80123C8F75F9C764D29DA814E4693C4854C0118AD3C0A60144E364D944D02C99F4F82100607600AC8F6365C91EC6CBB3A072C404011CE8025221D2A0337158200C97001F6978A1CE4FFBE7C4A5050402E9ECEE709D3FE7296A894F4C6A75467EB8959F4C013815C00FACEF38A7297F42AD2600B7006A0200EC538D51500010B88919624CE694C0027B91951125AFF7B9B1682040253D006E8000844138F105C0010D84D1D2304B213007213900D95B73FE914CC9FCBFA9EEA81802FA0094A34CA3649F019800B48890C2382002E727DF7293C1B900A160008642B87312C0010F8DB08610080331720FC580"
    bin_packets = convert_hex(hex)
    running :: Vector{Int64} = []
    number_box :: Vector{Int64}  = []
    consume_packet(bin_packets, running, number_box)
    println(sum(running))
    println(number_box[1])
end

problem0()
