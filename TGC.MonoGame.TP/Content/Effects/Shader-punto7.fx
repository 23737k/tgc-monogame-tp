#if OPENGL
	#define SV_POSITION POSITION
	#define VS_SHADERMODEL vs_3_0
	#define PS_SHADERMODEL ps_3_0
#else
	#define VS_SHADERMODEL vs_4_0_level_9_1
	#define PS_SHADERMODEL ps_4_0_level_9_1
#endif

float4x4 World;
float4x4 View;
float4x4 Projection;

//ESTE SHADER ES DE PLANTILLA. CONTIENE LO BASICO PARA CUALQUIER SHADER. SOLO DEVUELVE EL MODELO EN ESPACIO MUNDO CON UN COLOR AZUL.


/*
//Defino la textura

uniform texture ModelTexture;
sampler2D textureSampler = sampler_state
{
    Texture = (ModelTexture);
    MagFilter = Linear;
    MinFilter = Linear;
    AddressU = Clamp;
    AddressV = Clamp;
};
*/

uniform float4 Plano;

struct VertexShaderInput
{
	float4 Position : POSITION0;
	float2 TextureCoordinate : TEXCOORD0;
};

struct VertexShaderOutput
{
	float4 Position : SV_POSITION;
	float2 TextureCoordinate : TEXCOORD0;
	float4 WorldPosition : TEXCOORD1;
};


VertexShaderOutput MainVS(in VertexShaderInput input)
{
    // Clear the output
	VertexShaderOutput output = (VertexShaderOutput)0;
    // Model space to World space
    float4 worldPosition = mul(input.Position, World);
    // World space to View space
    float4 viewPosition = mul(worldPosition, View);	
	// View space to Projection space
    output.Position = mul(viewPosition, Projection);
	//Guardo la posicion de los vertices en World
	output.WorldPosition = worldPosition;
	return output;
}

float4 MainPS(VertexShaderOutput input) : COLOR
{
	//dot: retorna el producto escalar de dos vectores. 
    float dist = dot(Plano.xyz, input.WorldPosition.xyz) - Plano.w; // Calcular distancia del fragmento al plano
    if (dist > 0.0) // Si el fragmento está del lado opuesto al plano
        discard; // Descartar el fragmento
    
	 return float4(1.0, 0.0, 0.0, 1.0); // Dibujar el fragmento de color rojo
}


technique BasicColorDrawing
{
	pass P0
	{
		VertexShader = compile VS_SHADERMODEL MainVS();
		PixelShader = compile PS_SHADERMODEL MainPS();
	}
};