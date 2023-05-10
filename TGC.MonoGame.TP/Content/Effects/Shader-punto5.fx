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
	//propago las texturas
	output.TextureCoordinate = input.TextureCoordinate;
	//propago la posicion en World de los vertices
	output.WorldPosition = worldPosition;
	return output;
}

float4 MainPS(VertexShaderOutput input) : COLOR
{	 
   	//Ver como implementarlo con clip()
    float3 textureColor = tex2D(textureSampler, input.TextureCoordinate).rgb;
	//clip: si el valor dentro es menor que 0 (negativo) => descarta ese fragmento (no lo dibuja)
    clip(textureColor.g - 0.5);	
    clip(textureColor.b * 0.5);
    clip(distance(input.WorldPosition.xyz,float3(20.0, 20.0, 0.0))-20);
	return float4(textureColor,1);
}


technique BasicColorDrawing
{
	pass P0
	{
		VertexShader = compile VS_SHADERMODEL MainVS();
		PixelShader = compile PS_SHADERMODEL MainPS();
	}
};