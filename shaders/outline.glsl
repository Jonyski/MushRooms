extern number thickness = 1.0;
extern vec4 outlineColor = vec4(1.0, 1.0, 1.0, 1.0);

// passa por cada pixel da imagem e decide a cor final
vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords) {
  vec4 pixel = Texel(texture, texture_coords) * color;
  float alpha = pixel.a;

  // percorre vizinhança para detectar borda
  for (float x = -thickness; x <= thickness; x++) {
      for (float y = -thickness; y <= thickness; y++) {
        if (sqrt(pow(abs(x), 2) + pow(abs(y), 2)) > thickness) continue; // arredonda

        // pegamos quem é o maior alpha: se é do próprio pixel ou do vizinho
        vec2 offset = vec2(x, y) / love_ScreenSize.xy;
        alpha = max(alpha, Texel(texture, texture_coords + offset).a);
      }
  }

  // se o pixel atual é semitransparente e algum vizinho também, é um pixel de borda
  if (pixel.a < 0.1 && alpha > 0.1) return outlineColor;
  // se não, retorna o pixel do jeito que ele entrou
  return pixel;
}
