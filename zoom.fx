    // zoom.fx
    // by Findoss
     
    #include "ReShade.fxh"
     
    // KeyCodes
    // https://github.com/luluco250/FXShaders/blob/master/Shaders/KeyCodes.fxh
     
    #ifndef ZOOM_MODE
    #define ZOOM_MODE true
    #endif
     
    #ifndef ZOOM_KEY
    #define ZOOM_KEY 1
    #endif
     
    #ifndef ZOOM_DEVICE
    #define ZOOM_DEVICE "mousebutton"
    #endif
     
     //#define ZOOM_KEY 1
     //#define ZOOM_DEVICE = "mousebutton"
     
    uniform bool FollowMouse <
      ui_label   = "Follow Mouse";
      ui_tooltip = "May not be accurate."
                  "\nDefault: Off";
    > = false;
     
    uniform int Mode <
      ui_label   = "Zoom Switch";
      ui_tooltip = "Default: Hold";
      ui_type    = "combo";
      ui_items   = "Hold\0Toggle\0";
    > = 2;
     
    uniform float ZoomScale <
      ui_label   = "Zoom Scale";
      ui_tooltip = "How much zoom to apply to the image."
                  "\nFractional values zoom out."
                  "\nDefault: 2.0";
      ui_type    = "slider";
      ui_min     = 0.01;
      ui_max     = 10.0;
      ui_step    = 0.01;
    > = 3.0;
     
    uniform int Key <
      ui_label   = "Zoom Key";
      ui_tooltip = "..."
                  "\n..."
                  "\nDefault: 18 (KEY_ALT)";
      ui_type    = "input";
      ui_min     = 1;
      ui_max     = 1000;
      ui_step    = 1;
    > = 18;
     
    uniform float OffsetX <
      ui_label   = "Offset center position X";
      ui_tooltip = "offset position X in pixels"
                  "\nDefault: 0";
      ui_type    = "input";
    > = 0;
     
    uniform float OffsetY <
      ui_label   = "Offset center position Y";
      ui_tooltip = "offset position Y in pixels"
                  "\nDefault: 144 (2k)"
                  "\nDefault: 108 (FullHD)";
      ui_type    = "input";
    > = 0;
     
    uniform bool ZoomKey < // HUCK
      source  = ZOOM_DEVICE;
      keycode = ZOOM_KEY;
      press   = ZOOM_MODE;
    >;
     
    uniform float2 MousePoint <
      source = "mousepoint";
    >;
     
    sampler2D BackBuffer {
      Texture   = ReShade::BackBufferTex;
      MinFilter = LINEAR;
      MagFilter = LINEAR;
      MipFilter = LINEAR;
      AddressU  = BORDER;
      AddressV  = BORDER;
    };
     
    float2 scale_uv(float2 uv, float2 scale, float2 center) {
      return (uv - center) * scale + center;
    }
     
    float2 scale_uv(float2 uv, float2 scale) {
      return scale_uv(uv, scale, 0.5);
    }
     
    float4 PS_Zoom(
      float4 pos : SV_POSITION, 
      float2 uv : TEXCOORD
    ) : SV_TARGET {
      float2 center = float2( 
      0.5 + (OffsetX / BUFFER_WIDTH ),  
      0.5 + (OffsetY / BUFFER_HEIGHT ) 
      );
      float2 mousePosition = clamp(MousePoint, 0.0, ReShade::ScreenSize) * ReShade::PixelSize;
      float2 uv_zoom = scale_uv(
        uv, 
        ZoomKey ? (1.0 / ZoomScale) : 1.0, 
        FollowMouse ? mousePosition : center
      );
     
      float3 color = tex2D(BackBuffer, uv_zoom).rgb;
      return float4(color, 1.0);
    }
     
    technique Zoom {
      pass {
        VertexShader = PostProcessVS;
        PixelShader  = PS_Zoom;
      }
    }
