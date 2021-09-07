require "../bf.rb"

bm = BrainMem.new(true)

bm.exec do

  s = alloc(5)
  s.getstr(5)
  (4).downto(0) do |i|
    s[i].putchar
  end
  
end

# 実行
# bm.bf.make.dump_run(0.1)
bm.bf.run_dump

# # コード生成
puts bm.bf.to_s