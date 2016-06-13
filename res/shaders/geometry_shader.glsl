##GL_VERTEX_SHADER
#version 330

layout (location = 0) in vec3 in_position;
layout (location = 1) in vec2 in_texCoords;
layout (location = 2) in vec3 in_normal;

uniform mat4 MV;
uniform mat4 MVP;

out vec3 position;
out vec2 texCoords;
out vec3 normal;

void main()
{
	vec4 pos = vec4(in_position, 1.0);

	position = (MV * pos).xyz;
	texCoords = in_texCoords;
	normal = (MV * vec4(in_normal, 0.0)).xyz;

	gl_Position = MVP * pos;
}



##GL_FRAGMENT_SHADER
#version 330

in vec3 position;
in vec2 texCoords;
in vec3 normal;

struct point_light
{
	vec3 position;
	float radius;
	vec3 color;
};

#define MAX_POINT_LIGHTS 11

uniform sampler2D texture;
uniform float shininess;

uniform int numberOfPointLights;
uniform point_light pointLights[MAX_POINT_LIGHTS];

layout (location = 0) out vec3 out_position;
layout (location = 1) out vec3 out_normal;
layout (location = 2) out vec4 out_color;


void main()
{
	out_position.xyz = position;
	vec3 N = normalize(normal);
	out_normal.xyz = N;

	vec3 surfaceColor = texture2D(texture, texCoords).rgb;
	vec3 ambientColor = vec3(0.0);
	vec3 diffuseColor = vec3(0.0);

	for (int i = 0; i < min(MAX_POINT_LIGHTS, numberOfPointLights); ++i)
	{
		vec3 L = pointLights[i].position - position;
		float dist = length(L);
		L /= dist;

		float cosAngle = clamp(dot(L, N), 0.0, 1.0);

		float normDist = clamp(dist / pointLights[i].radius, 0.0, 1.0);
		float attenuation = 1.0 - normDist * normDist;

		ambientColor += surfaceColor * 0.05;
		diffuseColor += cosAngle * pointLights[i].color * surfaceColor * attenuation;
	}

	out_color.rgb = diffuseColor + ambientColor;
	out_color.a = shininess;

	out_color = vec4(1.0, 0, 0, 1);
}