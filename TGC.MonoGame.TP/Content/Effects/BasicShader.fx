#if OPENGL
	#define SV_POSITION POSITION
	#define VS_SHADERMODEL vs_3_0
	#define PS_SHADERMODEL ps_3_0
#else
	#define VS_SHADERMODEL vs_4_0_level_9_1
	#define PS_SHADERMODEL ps_4_0_level_9_1
#endif

// Custom Effects - https://docs.monogame.net/articles/content/custom_effects.html
// High-level shader language (HLSL) - https://docs.microsoft.com/en-us/windows/win32/direct3dhlsl/dx-graphics-hlsl
// Programming guide for HLSL - https://docs.microsoft.com/en-us/windows/win32/direct3dhlsl/dx-graphics-hlsl-pguide
// Reference for HLSL - https://docs.microsoft.com/en-us/windows/win32/direct3dhlsl/dx-graphics-hlsl-reference
// HLSL Semantics - https://docs.microsoft.com/en-us/windows/win32/direct3dhlsl/dx-graphics-hlsl-semantics

float4x4 World;
float4x4 View;
float4x4 Projection;

float Time = 0;


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
	float4 LocalPosition : TEXCOORD1; //agrego LocalPosition que guarda la posicion en local de cada vertice. Le puse TEXCOORD0 de semantics porque con POSITION0 no funca
	float4 ProjectedPosition : TEXCOORD2;  //Agrego esta variable que guarda lo mismo que Position, porque al usar esta ultima me tira error. Creo que esta protegida y no se puede usar
	float2 TextureCoordinate : TEXCOORD0;
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
	output.LocalPosition = input.Position; //Guardo la posicion local en el output
	output.ProjectedPosition = output.Position;
	output.TextureCoordinate = input.TextureCoordinate;
	return output;
}

float4 MainPS(VertexShaderOutput input) : COLOR
{	  
 
 float4 textureColor = tex2D(textureSampler, input.TextureCoordinate);
    textureColor.a = 1;
	// Color and texture are combined in this example, 80% the color of the texture and 20% that of the vertex
    return textureColor;
}



/*
Punto 3

//Declaro las variables uniformes 
uniform float Max;
uniform float Min;


VertexShaderOutput MainVS(in VertexShaderInput input)
{

// aca pregunto si el valor de x se pasa del maximo. si es asi entonces lo comprimo hasta el max. Analogo con el min
	if(input.Position.x >Max)
		input.Position.x = Max;
	if(input.Position.x <Min)
		input.Position.x = Min;

    // Clear the output
	VertexShaderOutput output = (VertexShaderOutput)0;
    // Model space to World space
    float4 worldPosition = mul(input.Position, World);
    // World space to View space
    float4 viewPosition = mul(worldPosition, View);	
	// View space to Projection space
    output.Position = mul(viewPosition, Projection);
	output.LocalPosition = input.Position; //Guardo la posicion local en el output
	output.ProjectedPosition = output.Position;

	return output;
}


float4 MainPS(VertexShaderOutput input) : COLOR
{	  
   float3 color = float3(0, 0, 0);
   return float4(color, 1.0);

}

*/

////////////////////////////////////////////////////////////////////////////////////////////////////


/*
Punto 2

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
	output.LocalPosition = input.Position; //Guardo la posicion local en el output
	output.ProjectedPosition = output.Position;
	return output;
}


float4 MainPS(VertexShaderOutput input) : COLOR
{	
	//Calculo la distancia entre la posicion proyectada y el centro de la esfera. Si la distancia es menor a 40 devuelve 1. Sino 0
   float colorValue= step(distance(float3(10.0, 10.0, 10.0), input.LocalPosition.xyz),40);
   float3 color = float3(colorValue, colorValue, colorValue);
   return float4(color, 1.0);
}
*/

technique BasicColorDrawing
{
	pass P0
	{
		VertexShader = compile VS_SHADERMODEL MainVS();
		PixelShader = compile PS_SHADERMODEL MainPS();
	}
};
