require "../bf.rb"

bm = BrainMem.new(true)

bm.exec do

  c = alloc
  c.getchar
  c.putchar

end

# 実行
bm.bf.run_dump

# コード生成
puts bm.bf.to_s
