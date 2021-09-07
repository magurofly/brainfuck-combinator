require "../bf.rb"

bm = BrainMem.new(true)

bm.exec do

  s = alloc 3
  s.setstr "ABC"
  s.putstr

  s.getstr 3
  s.putstr

end

# 実行
bm.bf.run_dump

# コード生成
puts bm.bf.to_s
