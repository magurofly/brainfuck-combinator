require "../bf.rb"

bm = BrainMem.new(true)

bm.exec do

  S = alloc(120)
  S.gets
  100.times do |i|
    alloc_tmps(5) do |t1, t2, t3, t4, t5|
      t4.copy S[i]
      t5.copy S[i]
      t1.ge t4, ?0
      t2.le t4, ?9
      t1.mul t2
      t1.if_nonzero do
        t3.copy t4
        t3.sub ?0.ord
        t3.times do
          t5.putchar
        end
      end
    end
  end
end

# 実行
# bm.bf.make.dump_run(0.1)
# bm.bf.run_dump

# # コード生成
puts bm.bf.to_s