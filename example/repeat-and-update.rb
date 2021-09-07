require "../bf.rb"

bm = BrainMem.new(true)

bm.exec do

  x = alloc(5)
  tmp = alloc
  y = alloc

  x.getstr
  tmp.getchar # 改行を読み捨て
  y.getdigit
  y.times do
    x.putstr
  end

end

# 実行
bm.bf.run_dump

# コード生成
puts bm.bf.to_s
