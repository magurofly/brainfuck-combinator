require "../bf.rb"

bm = BrainMem.new(true)

bm.exec do

  n = alloc(4)
  count = alloc
  cond = alloc

  n.getstr
  4.times do |i|
    cond.eq n[i], ?2
    cond.if_zero do
      count.add 1
    end
  end

  count.putdigit

end

# 実行
bm.bf.run_dump

# コード生成
puts bm.bf.to_s
