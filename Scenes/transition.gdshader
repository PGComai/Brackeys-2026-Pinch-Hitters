shader_type canvas_item;

instance uniform float progress : hint_range(0.0, 1.0) = 0.0;
uniform float diamondPixelSize : hint_range(1.0, 100.0) = 10.0;

void fragment() {
	float xFraction = fract(FRAGCOORD.x / diamondPixelSize);
	float yFraction = fract(FRAGCOORD.y / diamondPixelSize);
	float xDistance = abs(xFraction - 0.5);
	float yDistance = abs(yFraction - 0.5);
	if (xDistance + yDistance + UV.x + UV.y > progress * 4.0) {
		discard;
	}
}