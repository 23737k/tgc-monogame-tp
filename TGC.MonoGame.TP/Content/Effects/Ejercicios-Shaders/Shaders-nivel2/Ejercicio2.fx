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
uniform float Time;
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

struct VertexShaderInput
{
	float4 Position : POSITION0;
	float2 TextureCoordinate : TEXCOORD0;
};

struct VertexShaderOutput
{
	float4 Position : SV_POSITION;
	float2 TextureCoordinate : TEXCOORD0;
    float4 Color : TEXCOORD1;
};

float3 random3(float3 c)
{
    float j = 4096.0 * sin(dot(c, float3(17.0, 59.4, 15.0)));
    float3 r;
    r.z = frac(512.0 * j);
    j *= .125;
    r.x = frac(512.0 * j);
    j *= .125;
    r.y = frac(512.0 * j);
    return r;
}

VertexShaderOutput MainVS(in VertexShaderInput input)
{
    // Clear the output
	VertexShaderOutput output = (VertexShaderOutput)0;
    // Model space to World space
    float4 worldPosition = mul(input.Position, World);
    // World space to View space
    float4 viewPosition = mul(worldPosition, View);	
	// View space to Projection space
    float4 position = mul(viewPosition, Projection);
    output.Color = float4 (random3(position.xyz * Time),1);
    output.Position = position;

	return output;
}

float4 MainPS(VertexShaderOutput input) : COLOR
{	 
    return input.Color; 
}


technique BasicColorDrawing
{
	pass P0
	{
		VertexShader = compile VS_SHADERMODEL MainVS();
		PixelShader = compile PS_SHADERMODEL MainPS();
	}
};

//Funciones básicas de HLSL

// step(float x, float y): 		DEVUELVE 0 SI x<y. CASO CONTRARIO DEVUELVE 1
// saturate	(float x): 		UTILIZADA PARA RESTRINGIR (clamp) UN RANGO ENTRE [0,1]. RETORNA 0 SI x<0. RETORNA 1 SI x>1
// clamp (float value, float min, float max):	IGUAL QUE saturate PERO RESTRINGE value AL RANGO [min,max]
//  lerp (x, y, s):  	RETORNA UN VALOR QUE ESTA LINEALMENTE INTERPOLADO ENTRE x E y SEGUN s. Se puede pensar como que x es el start point e y es el end point. s es un factor 
						//que va de [0,1]. 0 indica el start point, y 1 el end point. Cualquier valor en medio, sera un pto ubicado entre el start point y el endpoint, sobre la recta
						//que los une
//  frac(float x): 	RETORNA LA PARTE FRACCIONARIA DE x
// length: 	RETORNA LA LONGITUD DEL VECTOR
//  distance: RETORNA LA DISTANCIA ENTRE DOS VECTORES
//   ceil(x) y floor(x):	 Retorna el entero mas pequeño que es mayor o igual a x. Retorna el entero mas grande que es menor igual a x. AKA: REDONDEA PARA ARRIBA O ABAJO
//  pow (X,Y)
//  clip(float x): DESCARTA EL FRAGMENTO O VERTICE SI x ES MENOR A 0; O SI LA CONDICION DEVUELVE FALSE.
// discard : DESCARTA EL FRAGMENTO O VERTICE 
// dot: producto escalar.