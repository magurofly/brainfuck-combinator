require "../bf.rb"

bm = BrainMem.new(true)

bm.exec do

  s = alloc(4 + 4 + 3)
  s.getstr(4 + 4 + 3)

  s[0].putchar
  s[4 + 1].putchar
  s[4 * 2 + 2].putchar

end

# 実行
bm.bf.run_dump

# コード生成
puts bm.bf.to_s
