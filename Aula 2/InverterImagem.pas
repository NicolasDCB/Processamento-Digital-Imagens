program InverterImagem;

uses SysUtils;

const
  MAX = 1000;

var
  img: array[1..MAX, 1..MAX] of integer;
  largura, altura: integer;
  i, j: integer;

begin
  { Simulando uma imagem 5x5 }
  largura := 5;
  altura := 5;

  { Preencher imagem com valores exemplo }
  for i := 1 to altura do
    for j := 1 to largura do
      img[i,j] := (i * j) * 10;

  { INVERTER IMAGEM }
  for i := 1 to altura do
    for j := 1 to largura do
      img[i,j] := 255 - img[i,j];

  { Mostrar resultado }
  for i := 1 to altura do
  begin
    for j := 1 to largura do
      write(img[i,j]:4);
    writeln;
  end;
end.