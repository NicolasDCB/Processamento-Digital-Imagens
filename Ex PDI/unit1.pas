unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ExtCtrls, StdCtrls,Buttons,
  Math;

type

  { TForm1 }

  TForm1 = class(TForm)
    BtnEqualizar: TButton;
    BtnEscala: TButton;
    BtnMediana: TButton;
    BtnRuido: TButton;
    BtnLimiar: TButton;
    BtnCarregar: TButton;
    BtnInverter: TButton;
    BtnLaplaciano: TButton;
    BtnMedia: TButton;
    BtnSobel: TButton;
    BtnBinarizar: TButton;
    Edit1: TEdit;
    EditC: TEdit;
    EditGama: TEdit;
    EditLimiar: TEdit;
    EditAng: TEdit;
    EditMag: TEdit;
    Image1: TImage;
    Image2: TImage;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    OpenDialog1: TOpenDialog;
    procedure BtnBinarizarClick(Sender: TObject);
    procedure BtnCarregarClick(Sender: TObject);
    procedure BtnEqualizarClick(Sender: TObject);
    procedure BtnEscalaClick(Sender: TObject);
    procedure BtnInverterClick(Sender: TObject);
    procedure BtnLaplacianoClick(Sender: TObject);
    procedure BtnLimiarClick(Sender: TObject);
    procedure BtnMediaClick(Sender: TObject);
    procedure BtnMedianaClick(Sender: TObject);
    procedure BtnRuidoClick(Sender: TObject);
    procedure BtnSobelClick(Sender: TObject);
    procedure Edit1Change(Sender: TObject);
    procedure EditCChange(Sender: TObject);
    procedure EditLimiarChange(Sender: TObject);
    procedure Image2MouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
    procedure Label2Click(Sender: TObject);
  private
    { Matrizes para armazenar Magnitude e Ângulo do gradiente }
    MatrizMag: array of array of Double;
    MatrizAng: array of array of Double;
  public

  end;

var
  Form1: TForm1;

implementation

{$R *.lfm}

{ TForm1 }

procedure TForm1.BtnCarregarClick(Sender: TObject);
begin
  if OpenDialog1.Execute then
  begin
    Image1.Picture.LoadFromFile(OpenDialog1.FileName);
    { Garante que o Bitmap interno esteja pronto para manipulação de pixels }
    Image1.Picture.Bitmap.Assign(Image1.Picture.Graphic);
  end;
end;

procedure TForm1.BtnEqualizarClick(Sender: TObject);
var
  x, y, i, tom: Integer;
  hist: array[0..255] of Integer;
  probAcum: array[0..255] of Double;
  totalPixels: Integer;
  BmpTemp: TBitmap;
begin
  for i := 0 to 255 do hist[i] := 0;
  totalPixels := Image1.Picture.Bitmap.Width * Image1.Picture.Bitmap.Height;

  // 1. Criar Histograma baseado na Image1
  for y := 0 to Image1.Picture.Bitmap.Height - 1 do
    for x := 0 to Image1.Picture.Bitmap.Width - 1 do
    begin
      tom := Red(Image1.Picture.Bitmap.Canvas.Pixels[x, y]);
      inc(hist[tom]);
    end;

  // 2. Calcular Probabilidade Acumulada
  probAcum[0] := hist[0] / totalPixels;
  for i := 1 to 255 do
    probAcum[i] := probAcum[i-1] + (hist[i] / totalPixels);

  // 3. Aplicar a transformação na Image2
  BmpTemp := TBitmap.Create;
  try
    BmpTemp.SetSize(Image1.Picture.Bitmap.Width, Image1.Picture.Bitmap.Height);
    for y := 0 to BmpTemp.Height - 1 do
      for x := 0 to BmpTemp.Width - 1 do
      begin
        tom := Red(Image1.Picture.Bitmap.Canvas.Pixels[x, y]);
        tom := Round(probAcum[tom] * 255); // Mapeia para o novo tom
        BmpTemp.Canvas.Pixels[x, y] := RGBToColor(tom, tom, tom);
      end;
    Image2.Picture.Bitmap.Assign(BmpTemp);
  finally
    BmpTemp.Free;
  end;
end;

procedure TForm1.BtnEscalaClick(Sender: TObject);
var
  x, y, tom: Integer;
  r, s, c, gama: Double;
  BmpTemp: TBitmap;
begin
  // Lê os valores dos Edits que você criou
  c := StrToFloatDef(EditC.Text, 1.0);
  gama := StrToFloatDef(EditGama.Text, 0.5);

  BmpTemp := TBitmap.Create;
  try
    BmpTemp.SetSize(Image1.Picture.Bitmap.Width, Image1.Picture.Bitmap.Height);
    for y := 0 to BmpTemp.Height - 1 do
      for x := 0 to BmpTemp.Width - 1 do
      begin
        // Normaliza o pixel original (r) para escala 0-1
        r := Red(Image1.Picture.Bitmap.Canvas.Pixels[x, y]) / 255;

        // Aplica a fórmula: S = c * (r ^ gama)
        s := c * Power(r, gama);

        // Converte de volta para 0-255
        tom := Round(s * 255);
        if tom > 255 then tom := 255;
        if tom < 0 then tom := 0;

        BmpTemp.Canvas.Pixels[x, y] := RGBToColor(tom, tom, tom);
      end;
    Image2.Picture.Bitmap.Assign(BmpTemp);
  finally
    BmpTemp.Free;
  end;
end;

procedure TForm1.BtnInverterClick(Sender: TObject);
var
  x, y: Integer;
  c: TColor;
  r, g, b: Byte;
begin
  Image2.Picture.Bitmap.SetSize(Image1.Picture.Bitmap.Width,
                                Image1.Picture.Bitmap.Height);

  for y := 0 to Image1.Picture.Bitmap.Height - 1 do
    for x := 0 to Image1.Picture.Bitmap.Width - 1 do
    begin
      c := Image1.Picture.Bitmap.Canvas.Pixels[x,y];

      r := 255 - Red(c);
      g := 255 - Green(c);
      b := 255 - Blue(c);

      Image2.Picture.Bitmap.Canvas.Pixels[x,y] := RGBToColor(r,g,b);
    end;
end;

procedure TForm1.BtnSobelClick(Sender: TObject);
var
  x, y: Integer;
  gx, gy: Double;
  gray: Integer;
begin
  { Redimensiona as matrizes e a imagem de saída }
  SetLength(MatrizMag, Image1.Picture.Bitmap.Width, Image1.Picture.Bitmap.Height);
  SetLength(MatrizAng, Image1.Picture.Bitmap.Width, Image1.Picture.Bitmap.Height);

  Image2.Picture.Bitmap.SetSize(Image1.Picture.Bitmap.Width,
                                Image1.Picture.Bitmap.Height);

  { Aplica o operador de Sobel (pula as bordas de 1 pixel) }
  for y := 1 to Image1.Picture.Bitmap.Height - 2 do
    for x := 1 to Image1.Picture.Bitmap.Width - 2 do
    begin
      { Gradiente em X }
      gx := -1 * Red(Image1.Picture.Bitmap.Canvas.Pixels[x-1,y-1]) +
             1 * Red(Image1.Picture.Bitmap.Canvas.Pixels[x+1,y-1]) +
            -2 * Red(Image1.Picture.Bitmap.Canvas.Pixels[x-1,y]) +
             2 * Red(Image1.Picture.Bitmap.Canvas.Pixels[x+1,y]) +
            -1 * Red(Image1.Picture.Bitmap.Canvas.Pixels[x-1,y+1]) +
             1 * Red(Image1.Picture.Bitmap.Canvas.Pixels[x+1,y+1]);

      { Gradiente em Y }
      gy := -1 * Red(Image1.Picture.Bitmap.Canvas.Pixels[x-1,y-1]) -
             2 * Red(Image1.Picture.Bitmap.Canvas.Pixels[x,y-1]) -
             1 * Red(Image1.Picture.Bitmap.Canvas.Pixels[x+1,y-1]) +
             1 * Red(Image1.Picture.Bitmap.Canvas.Pixels[x-1,y+1]) +
             2 * Red(Image1.Picture.Bitmap.Canvas.Pixels[x,y+1]) +
             1 * Red(Image1.Picture.Bitmap.Canvas.Pixels[x+1,y+1]);

      { Calcula Magnitude e Ângulo }
      MatrizMag[x,y] := sqrt(gx*gx + gy*gy);
      MatrizAng[x,y] := arctan2(gy, gx);

      { Converte magnitude para escala de cinza (0-255) }
      gray := Round(MatrizMag[x,y]);
      if gray > 255 then gray := 255;

      Image2.Picture.Bitmap.Canvas.Pixels[x,y] := RGBToColor(gray,gray,gray);
    end;
end;

procedure TForm1.Edit1Change(Sender: TObject);
begin

end;

procedure TForm1.EditCChange(Sender: TObject);
begin

end;

procedure TForm1.EditLimiarChange(Sender: TObject);
begin

end;

procedure TForm1.BtnLimiarClick(Sender: TObject);
var
  x, y, gray, T: Integer;
  c: TColor;
begin
  // Lê o valor T definido pelo usuário no EditLimiar
  T := StrToIntDef(EditLimiar.Text, 127);
  Image2.Picture.Bitmap.SetSize(Image1.Picture.Bitmap.Width, Image1.Picture.Bitmap.Height);

  for y := 0 to Image1.Picture.Bitmap.Height - 1 do
    for x := 0 to Image1.Picture.Bitmap.Width - 1 do
    begin
      c := Image1.Picture.Bitmap.Canvas.Pixels[x,y];
      gray := (Red(c) + Green(c) + Blue(c)) div 3;

      // Limiarização baseada no valor T
      if gray > T then gray := 255 else gray := 0;

      Image2.Picture.Bitmap.Canvas.Pixels[x,y] := RGBToColor(gray, gray, gray);
    end;
end;

// 2. Filtro da Média (Suaviza a imagem e borra o ruído)
procedure TForm1.BtnMediaClick(Sender: TObject);
var
  x, y, i, j, soma: Integer;
  BmpIn, BmpOut: TBitmap;
begin
  BmpIn := TBitmap.Create;
  BmpOut := TBitmap.Create;
  try
    // Prepara a imagem de entrada e saída
    BmpIn.Assign(Image2.Picture.Bitmap);
    BmpIn.PixelFormat := pf24bit;
    BmpOut.SetSize(BmpIn.Width, BmpIn.Height);
    BmpOut.PixelFormat := pf24bit;

    // Filtro da Média usando Canvas.Pixels (mais seguro para evitar erros de borda)
    for y := 1 to BmpIn.Height - 2 do
      for x := 1 to BmpIn.Width - 2 do
      begin
        soma := 0;
        for j := -1 to 1 do
          for i := -1 to 1 do
            soma := soma + Red(BmpIn.Canvas.Pixels[x+i, y+j]);

        soma := soma div 9;
        BmpOut.Canvas.Pixels[x, y] := RGBToColor(soma, soma, soma);
      end;

    Image2.Picture.Bitmap.Assign(BmpOut);
  finally
    BmpIn.Free;
    BmpOut.Free;
  end;
end;

// Função auxiliar para o Filtro de Mediana (Coloque antes das procedures dos botões)
procedure Sort(var A: array of Integer);
var
  i, j, temp: Integer;
begin
  for i := Low(A) to High(A) do
    for j := i + 1 to High(A) do
      if A[i] > A[j] then
      begin
        temp := A[i];
        A[i] := A[j];
        A[j] := temp;
      end;
end;

// 3. Filtro da Mediana (Excelente para remover ruído Sal e Pimenta)
procedure TForm1.BtnMedianaClick(Sender: TObject);
var
  x, y, i, j, k: Integer;
  vizinhos: array[0..8] of Integer;
begin
  Image2.Picture.Bitmap.SetSize(Image1.Picture.Bitmap.Width, Image1.Picture.Bitmap.Height);

  for y := 1 to Image1.Picture.Bitmap.Height - 2 do
    for x := 1 to Image1.Picture.Bitmap.Width - 2 do
    begin
      k := 0;
      for j := -1 to 1 do
        for i := -1 to 1 do
        begin
          vizinhos[k] := Red(Image1.Picture.Bitmap.Canvas.Pixels[x+i, y+j]);
          inc(k);
        end;

      Sort(vizinhos); // Ordena os 9 vizinhos
      // O valor da mediana é o do meio (índice 4)
      Image2.Picture.Bitmap.Canvas.Pixels[x, y] := RGBToColor(vizinhos[4], vizinhos[4], vizinhos[4]);
    end;
end;

// 1. Gerar Ruído Sal e Pimenta (10% da imagem)
procedure TForm1.BtnRuidoClick(Sender: TObject);
var
  x, y, i, qtdPixels, sorteio: Integer;
begin
  // Copia a imagem 1 para a imagem 2 antes de sujar
  Image2.Picture.Bitmap.Assign(Image1.Picture.Bitmap);

  qtdPixels := (Image2.Picture.Bitmap.Width * Image2.Picture.Bitmap.Height) div 10; // 10%

  for i := 1 to qtdPixels do
  begin
    x := Random(Image2.Picture.Bitmap.Width);
    y := Random(Image2.Picture.Bitmap.Height);

    sorteio := Random(2); // 0 ou 1
    if sorteio = 0 then
      Image2.Picture.Bitmap.Canvas.Pixels[x, y] := clBlack
    else
      Image2.Picture.Bitmap.Canvas.Pixels[x, y] := clWhite;
  end;
end;

procedure TForm1.BtnBinarizarClick(Sender: TObject);
var
  x, y, gray: Integer;
  c: TColor;
begin
  Image2.Picture.Bitmap.SetSize(Image1.Picture.Bitmap.Width, Image1.Picture.Bitmap.Height);

  for y := 0 to Image1.Picture.Bitmap.Height - 1 do
    for x := 0 to Image1.Picture.Bitmap.Width - 1 do
    begin
      c := Image1.Picture.Bitmap.Canvas.Pixels[x,y];
      gray := (Red(c) + Green(c) + Blue(c)) div 3;

      // Binarização simples (fixa em 128)
      if gray > 128 then gray := 255 else gray := 0;

      Image2.Picture.Bitmap.Canvas.Pixels[x,y] := RGBToColor(gray, gray, gray);
    end;
end;

procedure TForm1.BtnLaplacianoClick(Sender: TObject);
var
  x, y, valor: Integer;
begin
  Image2.Picture.Bitmap.SetSize(Image1.Picture.Bitmap.Width, Image1.Picture.Bitmap.Height);

  // Filtro Laplaciano (Vizinhança 4)
  // Máscara:  0  1  0
  //           1 -4  1
  //           0  1  0
  for y := 1 to Image1.Picture.Bitmap.Height - 2 do
    for x := 1 to Image1.Picture.Bitmap.Width - 2 do
    begin
      valor := (Red(Image1.Picture.Bitmap.Canvas.Pixels[x, y-1]) * 1) +
               (Red(Image1.Picture.Bitmap.Canvas.Pixels[x-1, y]) * 1) +
               (Red(Image1.Picture.Bitmap.Canvas.Pixels[x, y]) * -4) +
               (Red(Image1.Picture.Bitmap.Canvas.Pixels[x+1, y]) * 1) +
               (Red(Image1.Picture.Bitmap.Canvas.Pixels[x, y+1]) * 1);

      // Normaliza para o intervalo 0-255
      valor := Abs(valor);
      if valor > 255 then valor := 255;

      Image2.Picture.Bitmap.Canvas.Pixels[x,y] := RGBToColor(valor, valor, valor);
    end;
end;

procedure TForm1.Image2MouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
begin
  { Verifica se as matrizes já foram criadas para evitar erro de Access Violation }
  if (Length(MatrizMag) > 0) and (X < Length(MatrizMag)) and (Y < Length(MatrizMag[0])) then
  begin
    EditMag.Text := FloatToStr(MatrizMag[X,Y]);
    EditAng.Text := FloatToStr(MatrizAng[X, Y]);
  end;
end;

procedure TForm1.Label2Click(Sender: TObject);
begin

end;

end.
