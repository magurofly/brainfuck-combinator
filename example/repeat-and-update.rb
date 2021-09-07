require "../bf.rb"

bm = BrainMem.new(true)

bm.exec do

  x = alloc(6)
  x.setstr "hello\n"
  y = alloc
  y.getdigit
  y.times do
    x.putstr
    x[0].add 1
  end

end

# コードの生成
bm.bf.run_dump
