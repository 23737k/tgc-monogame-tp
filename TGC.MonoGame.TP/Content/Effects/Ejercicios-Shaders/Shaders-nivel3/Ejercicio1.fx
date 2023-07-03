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
float4x4 InverseTransposeWorld;

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
	float4 Normal : NORMAL;
};

struct VertexShaderOutput
{
	float4 Position : SV_POSITION;
	float2 TextureCoordinate : TEXCOORD0;
	float4 WorldPosition : TEXCOORD1;
	float4 Normal : TEXCOORD2;
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
	//Obtengo la normal
	output.Normal = mul(float4(normalize(input.Normal.xyz),1.0),InverseTransposeWorld);
	return output;
}

float4 MainPS(VertexShaderOutput input) : COLOR
{	 
	float3 cameraDirection = normalize(input.WorldPosition- mul(input.WorldPosition, View));
	float3 normal = normalize(input.Normal.xyz);
	float CdotN = saturate(dot(cameraDirection,normal));


	//REMEMBER: LUZ MAS INTENSA IMPLICA QUE LE AFECTA MENOS EL ALPHA BLENDING. ES DECIR PARA VALORES DEL TIPO (1,1,1,1) EL ALPHA BLENDING CASI NO SE VA A NOTAR. 
	//TENER CUIDADO CON LA DIRECCION DEL VECTOR DIRECCION (VER EL ORDEN DE LAS RESTAS)
	//
	if(CdotN <0.01)
		discard;
	float4 color = float4(1-CdotN-0.4,1-CdotN-0.4,1-CdotN+0.5, 1-CdotN-0.4);
	return color;
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