# brainfuck-combinator

## 使い方

```bash
$ irb -r ./bf.rb
irb> b = BrainMem.new(false) # trueだと詳細な出力
irb>
```

## 機能

* `x = b.alloc(size = 1)`: 連続したメモリを確保、ポインタを返す
* `x.free`: メモリを解放（※freeする前に0にしないと壊れるかも）
* `b.alloc_tmp { |ptr| ... }`: 一時的にメモリを確保
* `b.go_to x`: `x`がある位置にBrainfuckのポインタを移動させる
* `b.zero(dst)`: dstを0にする
* `b.move(dst, src)`: srcをdstに移動する（srcは0になる）
* `b.copy(dst, src)`: srcをdstにコピーする
* `x.set(y)`: xにyを代入する
* `x.add(y)`: 8ビット符号なし整数の加算（yはポインタか値）
* `x.sub(y)`: 8ビット符号なし整数の減算（yはポインタか値）
* `x.mul(y)`: 8ビット符号なし整数の乗算（yはポインタか値）
* `x.times { ... }`: `x`の回数だけ繰り返す
* `x.if_nonzero { ... }`: `x`が0でなければ実行
