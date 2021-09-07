require "../bf.rb"

bm = BrainMem.new(true)

bm.exec do

  n = alloc
  n.add 1
  n.putdigit

end

# 実行
# bm.bf.make.dump_run(0.1)
bm.bf.run_dump

# # コード生成
puts bm.bf.to_s