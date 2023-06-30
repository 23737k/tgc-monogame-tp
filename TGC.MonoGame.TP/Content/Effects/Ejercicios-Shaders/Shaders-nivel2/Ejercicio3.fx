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
    float4 position = input.Position;
    // Model space to World space
    float4 worldPosition = mul(position, World);

    //ACA UTILIZO LA FUNCION RANDOM PARA QUE ME DEVUELVA UN NUMERO ALEATORIO. LO MULTIPLICO POR Time PARA QUE DEPENDA DEL TIEMPO, YA QUE AL PARECER AUNQUE EL SHADER SE EJECUTE EN 
    //CADA Draw() Y random3 DEVUELVA UN NUMERO ALEATORIO CADA VEZ, EL MODELO SE VE QUIETO. AL PARECER NO SE VUELVE A EJECUTAR random3 A MENOS QUE SE LO MULTIPLIQUE POR UNA VARIABLE
    //CAMBIANTE COMO Time. 
    //CON ESTE float3 ALEATORIO, OBTENGO SUS COMPONENTES XZ (YA QUE SOLO ME PIDEN QUE VARIE LA POSICION DE LOS VERTICES EN ESTOS EJES), Y EN LUGAR DE ASIGNARLOS COMO LOS NUEVOS
    //x z DEL VERTICE, LO UTILIZO COMO UN OFFSET DEL DESPLAZAMIENTO. NO FUNCIONA CAMBIANDO LOS VALORES DE X Z DEL VERTICE POR LOS VALORES ARROJADOS POR random3 YA 
    //QUE AL PARECER ESTA FUNCION ARROJA VALORES MUY PEQUEÑOS, POR LO TANTO CUANDO SE INTENTA HACER LO ANTES MENCIONADO : SE VE UNA LINEA, SI SE MODIFICAN X Z (DOS EJES), 
    //SE VE EL MODELO ACHATADO, SI SE MODIFICA X o Z (1 EJE), O SE VE UN PUNTO SI SE INTENTA MODIFICAR X Y Z (LOS 3 EJES). 
    //ES POR ESO QUE A SUS COMPONENTES EN X Z LES SUMO LO DEVUELTO POR random3.

    float2 offset= random3(worldPosition.xyz * Time).xz;
    worldPosition.xz += offset;
    // World space to View space
    float4 viewPosition = mul(worldPosition, View);	
	// View space to Projection space
    output.Position = mul(viewPosition, Projection);
	//propago las texturas
	output.TextureCoordinate = input.TextureCoordinate;
	//propago la posicion en World de los vertices
	//output.WorldPosition = worldPosition;
	return output;
}

float4 MainPS(VertexShaderOutput input) : COLOR
{	 
    //Multiplicacion de colores: da una apariencia más oscurecida o atenuada del color original. Se utiliza para hacer mezclas o atenuaciones de colores
    //Suma de colores: da una apariencia más brillante o intensa. Esto puede resaltar o intensificar (brillante) el color original.
    return float4(tex2D(textureSampler, input.TextureCoordinate).rgb,1) * float4(0,0.8,0,1); 
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