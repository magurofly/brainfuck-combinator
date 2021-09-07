# brainfuck-combinator

## 使い方

```bash
$ irb -r ./bf.rb
irb> b = BrainMem.new(false) # trueだと詳細な出力
irb> # コードを書く
irb> puts b.bf.to_s # Brainfuckコードを出力
```

## 機能

### メモリ

* `x = b.alloc(size = 1)`: 連続したメモリを確保、ポインタを返す
* `x.free`: メモリを解放（※freeする前に0にしないと壊れるかも）
* `b.alloc_tmp { |ptr| ... }`: 一時的にメモリを確保
* `b.go_to x`: `x`がある位置にBrainfuckのポインタを移動させる
* `b.zero(dst)`: dstを0にする
* `b.move(dst, src)`: srcをdstに移動する（srcは0になる）
* `b.copy(dst, src)`: srcをdstにコピーする
* `x.set(y)`: xにyを代入する

### 算術演算
* `x.add(y)`: 8ビット符号なし整数の加算（yはポインタか値）
* `x.sub(y)`: 8ビット符号なし整数の減算（yはポインタか値）
* `x.mul(y)`: 8ビット符号なし整数の乗算（yはポインタか値）

### 論理演算
* `x.not`

### 比較演算
* `x.eq(y, z)`: `y == z`の結果を`x`に格納
* `x.ne(y, z)`: `y != z`の結果を`x`に格納
* `x.lt(y, z)`: `y < z`の結果を`x`に格納
* `x.le(y, z)`: `y <= z`の結果を`x`に格納
* `x.gt(y, z)`: `y > z`の結果を`x`に格納
* `x.ge(y, z)`: `y >= z`の結果を`x`に格納

### 制御
* `x.times { ... }`: `x`の回数だけ繰り返す
* `x.if_nonzero { ... }`: `x`が0でなければ実行
* `x.if_zero { ... }`: `x`が0なら実行
* `x.while_nonzero { ... }`: `x`が0でない間繰り返す
* `x.while_zero { ... }`: `x`が0の間繰り返す

## バグ

なんか比較系の演算をするときにどこかのメモリがずれてるらしい　涙
