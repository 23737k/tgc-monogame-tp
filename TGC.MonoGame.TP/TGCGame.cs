﻿using System;
using Microsoft.Xna.Framework;
using Microsoft.Xna.Framework.Graphics;
using Microsoft.Xna.Framework.Input;

namespace TGC.MonoGame.TP
{
    /// <summary>
    ///     Esta es la clase principal del juego.
    ///     Inicialmente puede ser renombrado o copiado para hacer mas ejemplos chicos, en el caso de copiar para que se
    ///     ejecute el nuevo ejemplo deben cambiar la clase que ejecuta Program <see cref="Program.Main()" /> linea 10.
    /// </summary>
    public class TGCGame : Game
    {
        public const string ContentFolder3D = "Models/";
        public const string ContentFolderEffects = "Effects/";
        public const string ContentFolderMusic = "Music/";
        public const string ContentFolderSounds = "Sounds/";
        public const string ContentFolderSpriteFonts = "SpriteFonts/";
        public const string ContentFolderTextures = "Textures/";

        /// <summary>
        ///     Constructor del juego.
        /// </summary>
        public TGCGame()
        {
            // Maneja la configuracion y la administracion del dispositivo grafico.
            Graphics = new GraphicsDeviceManager(this);
            // Para que el juego sea pantalla completa se puede usar Graphics IsFullScreen.
            // Carpeta raiz donde va a estar toda la Media.
            Content.RootDirectory = "Content";
            // Hace que el mouse sea visible.
            IsMouseVisible = true;
        }

        private GraphicsDeviceManager Graphics { get; }
        private SpriteBatch SpriteBatch { get; set; }
        private Model Model { get; set; }
        private Effect Effect { get; set; }
        private float Rotation { get; set; }
        private Matrix World { get; set; }
        private Matrix View { get; set; }
        private Matrix Projection { get; set; }

        /// <summary>
        ///     Se llama una sola vez, al principio cuando se ejecuta el ejemplo.
        ///     Escribir aqui el codigo de inicializacion: el procesamiento que podemos pre calcular para nuestro juego.
        /// </summary>
        protected override void Initialize()
        {
            // La logica de inicializacion que no depende del contenido se recomienda poner en este metodo.

            // Apago el backface culling.
            // Esto se hace por un problema en el diseno del modelo del logo de la materia.
            // Una vez que empiecen su juego, esto no es mas necesario y lo pueden sacar.
            var rasterizerState = new RasterizerState();
            rasterizerState.CullMode = CullMode.None;
            GraphicsDevice.RasterizerState = rasterizerState;
            // Seria hasta aca.

            // Configuramos nuestras matrices de la escena.
            //Vector3 vector= new Vector3(1f,0f,2f);    Crea un vector en R3
            //Vector3.UnitZ -> me devuelve un vector (0f,0f,1f)     vector unitario en Z

            World = Matrix.Identity;
            View = Matrix.CreateLookAt(Vector3.UnitZ * 150, Vector3.Zero, Vector3.Up);
            Projection =
                Matrix.CreatePerspectiveFieldOfView(MathHelper.PiOver4, GraphicsDevice.Viewport.AspectRatio, 1, 250);
            //PiOver4 (medida mas comun para el angulo de apertura del frostum). AspectRatio dado por Monogame 
            base.Initialize();
        }

        /// <summary>
        ///     Se llama una sola vez, al principio cuando se ejecuta el ejemplo, despues de Initialize.
        ///     Escribir aqui el codigo de inicializacion: cargar modelos, texturas, estructuras de optimizacion, el procesamiento
        ///     que podemos pre calcular para nuestro juego.
        /// </summary>
        protected override void LoadContent()
        {
            // Aca es donde deberiamos cargar todos los contenido necesarios antes de iniciar el juego.
            SpriteBatch = new SpriteBatch(GraphicsDevice);

            // Cargo el modelo del logo.
            Model = Content.Load<Model>(ContentFolder3D + "tgc-logo/tgc-logo");

            // Cargo un efecto basico propio declarado en el Content pipeline.
            // En el juego no pueden usar BasicEffect de MG, deben usar siempre efectos propios.
            Effect = Content.Load<Effect>(ContentFolderEffects + "BasicShader");

            // Asigno el efecto que cargue a cada parte del mesh.
            // Un modelo puede tener mas de 1 mesh internamente.
            foreach (var mesh in Model.Meshes)
            {
                // Un mesh puede tener mas de 1 mesh part (cada 1 puede tener su propio efecto).
                foreach (var meshPart in mesh.MeshParts)
                {
                    meshPart.Effect = Effect;
                }
            }

            base.LoadContent();
        }

        /// <summary>
        ///     Se llama en cada frame.
        ///     Se debe escribir toda la logica de computo del modelo, asi como tambien verificar entradas del usuario y reacciones
        ///     ante ellas.
        /// </summary>

         float yPosition=0f;
         float xPosition=0f;
         float scale=1f;
        protected override void Update(GameTime gameTime)
        {
            // Aca deberiamos poner toda la logica de actualizacion del juego.

            // Capturar Input teclado
            if (Keyboard.GetState().IsKeyDown(Keys.Escape))
            {
                //Salgo del juego.
                Exit();
            }

            /*gameTime.ElapsedGameTime.TotalSeconds: 
                    tiempo en seg que paso desde el ultimo UPDATE. En general el tiempo es siempre el mismo y varia de maquina en maquina
              gameTime.TotalGameTime.TotalSeconds: 
                    tiempo en seg desde que se inicio el juego. Se va incrementando.
            */
            if(Keyboard.GetState().IsKeyDown(Keys.W))
                yPosition += 10* Convert.ToSingle(gameTime.ElapsedGameTime.TotalSeconds);     //Convert.ToSingle(double): convierte a float
                       
            if(Keyboard.GetState().IsKeyDown(Keys.S))
                yPosition -= 10* Convert.ToSingle(gameTime.ElapsedGameTime.TotalSeconds);

            if(Keyboard.GetState().IsKeyDown(Keys.D))
                xPosition = MathF.Cos(Convert.ToSingle(gameTime.TotalGameTime.TotalSeconds))*100;            

            if(Keyboard.GetState().IsKeyDown(Keys.A))
                 xPosition -= 10* Convert.ToSingle(gameTime.ElapsedGameTime.TotalSeconds);

            if(Keyboard.GetState().IsKeyDown(Keys.Space))
                scale= MathF.Cos(Convert.ToSingle(gameTime.TotalGameTime.TotalSeconds))+2f;

            Rotation += Convert.ToSingle(gameTime.ElapsedGameTime.TotalSeconds);

            Quaternion quaternion;
            var axis= new Vector3(1f,1f,0f);
            axis.Normalize(); // siempre hay que normalizar el vector que le pasamos a quaternion
            quaternion=Quaternion.CreateFromAxisAngle(axis,Rotation);     //Le indico el vector eje sobre el que va a girar y el angulo de giro (en este caso incremental)
            
            World = 
                Matrix.CreateTranslation(xPosition,yPosition,0f)
                * Matrix.CreateFromQuaternion(quaternion)
                * Matrix.CreateScale(scale);    //Indico el factor de escala. 1 es el tamaño original

            

            base.Update(gameTime);
        }

        /// <summary>
        ///     Se llama cada vez que hay que refrescar la pantalla.
        ///     Escribir aqui el codigo referido al renderizado.
        /// </summary>
        protected override void Draw(GameTime gameTime)
        {
            // Aca deberiamos poner toda la logia de renderizado del juego.
            GraphicsDevice.Clear(Color.Black);

            // Para dibujar le modelo necesitamos pasarle informacion que el efecto esta esperando.
            Effect.Parameters["View"].SetValue(View);
            Effect.Parameters["Projection"].SetValue(Projection);
            Effect.Parameters["DiffuseColor"].SetValue(Color.DarkBlue.ToVector3());
            var rotationMatrix = Matrix.CreateRotationY(Rotation);

            foreach (var mesh in Model.Meshes)
            {
                //World = mesh.ParentBone.Transform * rotationMatrix;
                Effect.Parameters["World"].SetValue(World);
                mesh.Draw();
            }
        }

        /// <summary>
        ///     Libero los recursos que se cargaron en el juego.
        /// </summary>
        protected override void UnloadContent()
        {
            // Libero los recursos.
            Content.Unload();

            base.UnloadContent();
        }
    }
}