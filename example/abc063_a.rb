require "../bf.rb"

bm = BrainMem.new(true)

bm.exec do

  a = alloc
  b = alloc
  c = alloc

  a.getdigit
  c.getchar
  b.getdigit

  c.zero
  c.add a
  c.add b

  d = alloc
  d.ge c, 10
  d.if_nonzero do
    puts "error"
  end
  d.if_zero do
    c.putdigit
  end

end

# 実行
bm.bf.run_dump

# コード生成
puts bm.bf.to_s
