MESSAGES =
  [
    [{15 => 6512}, "78b170"],
    [{tag15: 6512}, "78b170", {tag15: 15}],
    [{129 => 6512}, "f88001b170"],
    [{0 => -1}, "0101"],
    [{0 => "text"}, "020474657874"],
    [{0 => "text".force_encoding(Encoding::BINARY)}, "030474657874"],
    [{0 => true}, "04"],
    [{0 => false}, "05"],
    [{0 => 3.1415}, "066f1283c0ca210940"],
    [
      {
        1 => "Föo",
        200 => "hihi".force_encoding(Encoding::BINARY),
        3 => true,
        40 => false,
      },
      "0a0446c3b66ffb804804686968691cfd28"
    ],
    [
      {
        2 => true,
        tag1: [false, 5, "text", "bytes".force_encoding(Encoding::BINARY), 1.11],
        tag0: 100,
      },
      "140d08050a04746578740b0562797465730ec3f5285c8fc2f13f0064",
      [:tag0, :tag1]
    ]
  ]
