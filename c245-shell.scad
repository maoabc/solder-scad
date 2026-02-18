
// 引入BOSL2库
include <BOSL2/std.scad>
include <BOSL2/threading.scad>
include <BOSL2/screws.scad>




// 参数定义
                              
handle_width = 15;            // 手柄宽度（X方向）
handle_thickness = 12;        // 手柄厚度（Y方向）
handle_length = 91;          // 手柄主体长度
                             
ring_h = 8.5;                 // 圆环长度
transition_length = 3;        // 过渡段长度
corner_radius = 6;            // 圆角半径（Z轴四棱）
                              //
handle_inner_width = 11;            // 手柄内部宽度（X方向）
handle_inner_thickness = 8;        // 手柄内部厚度
inner_corner_radius = 4;            // 内部圆角半径（Z轴四棱）


//pcb尺寸信息
pcb_w=91+0.1;
pcb_h=12+0.3;
pcb_t=1.6+0.2;


//lcd外部轮廓，最大误差再额外增加0.2
lcd_h=8.6+0.1+0.2;
lcd_w=29.8+0.1+0.2;
lcd_t=1.5+0.1+0.1;


screen_h=6.00;//屏幕显示区域高度，比6.095稍微小些
screen_w=24.3;//屏幕显示区域宽度，比24.385小

module tft_n099_display(w=lcd_w,h=lcd_h,t=lcd_t,show_screen=true){
    //把lcd显示面旋转到面向Y轴负方向
        rotate([0,270,90])
        union(){
            //0.99寸tft屏幕，分辨率40*160
            //屏幕Z轴为厚度
            cuboid([w,h,t],anchor=LEFT+FRONT+BOTTOM);
            //x轴中心对齐
            if(show_screen){
                translate([4.2,(h-screen_h)/2,0])
                    color("blue") cuboid([screen_w,screen_h,15],anchor=LEFT+FRONT+BOTTOM);//可显示区域,厚度设置足够高方便验证屏幕区域是否被正确挖空
            }
        }
}

//
// 倒角模块（只针对显示区域）
module chamfer_screen() {
    //把lcd显示面移动旋转到面向Y轴负方向
            //大于屏幕，在屏幕上一个手柄外壳的距离
            inc_w=6;
            inc_h=3;
    color("green") 
            translate([-screen_h/2,-3,4.2])
                cuboid([screen_h,3,screen_w],anchor=LEFT+FRONT+BOTTOM);

}

module keycap(key_h=2.5,key_d=3,fill=true) {
    difference() {
        union() {
            cyl(h=1.5, d=key_d+2,anchor=BOTTOM);
            translate([0, 0, 1.5])
                cyl(h=key_h, d=key_d, rounding2=0.5,anchor=BOTTOM); // 顶部圆角
        }
        if(!fill){
            cyl(h=key_h, d=1.5,anchor=BOTTOM);
        }
    }
}

//C388295按键,按键高度根据型号调整
module key(){
    //使用键帽进行diff,增加余量保证顺畅按压
    //按键半径比实际大0.05
    color("red")
        //按键2mm
        translate([0,0,2+0.1])
        keycap(key_d=3.1);
    rotate([0,0,270]){
        translate([-2.7,-3.2,0])
            cuboid([5.2,6.4,1.2],anchor=LEFT+FRONT+BOTTOM);

    }
}

module type_c(){
    // Type-C 尺寸
    typec_width = 8.94+0.1;  // X 轴
    typec_thickness = 3.16+0.1;  // Y 轴
    typec_height = 20; //长度比上盖厚度大就行，保证可以在盖子上打孔 

    rotate([90,0,90])
    translate([pcb_h/2, -typec_thickness/2, pcb_w-15])  //把tpyec在pcb上面深度大些保证正确插入
        color("red")cuboid([typec_width, typec_thickness, typec_height],
                rounding=1.5,
                edges=[FRONT+LEFT, FRONT+RIGHT, BACK+LEFT, BACK+RIGHT],
                anchor=BOTTOM);
}

//pcb
module c245_pcb(){
    translate([pcb_h/2,pcb_t/2,0])
        rotate([0,270,90])
        union(){
            cuboid([pcb_w,pcb_h,pcb_t],anchor=LEFT+FRONT+BOTTOM);
            translate([43,pcb_h/2,pcb_t])
                key();
            translate([50,pcb_h/2,pcb_t])
                key();
            //模拟突起的电容
            translate([pcb_w-7.5-30,2,pcb_t])
                cuboid([30,4.5,2],anchor=LEFT+FRONT+BOTTOM);
            type_c();
        }

}

module pcb_solt(t=1, w=1, h=35) {
    translate([0,-(pcb_t/2+t),0])
        cuboid([w,pcb_t+2*t,35],anchor=LEFT+FRONT+BOTTOM);
}

//lcd相对于手柄底部的位置
lcd_off=53.5;

m1_6_fore=88;
m1_6_back=42.5;


//手柄主体部分
module handle(){
    //m1.6螺丝轮廓，用于给手柄增加螺丝孔
    module m1_6(m=1.6){
        //螺帽直径3mm,厚度不用管能方便diff就行
        cylinder(1,d=3+0.1);
        //螺纹1.6mm
        translate([0,0,1])
            cylinder(3,d=m+0.1);
    }
    difference(){
        union(){
            difference(){
                //手柄基础外形，挖孔的圆角长方体
                cuboid([handle_width, handle_thickness, handle_length], 
                        rounding=corner_radius, 
                        edges=[FRONT+LEFT, FRONT+RIGHT, BACK+LEFT, BACK+RIGHT], 
                        anchor=BOTTOM);

                translate([0,0,-0.1])
                    cuboid([handle_inner_width, handle_inner_thickness, handle_length+1], 
                            rounding=inner_corner_radius, 
                            edges=[FRONT+LEFT, FRONT+RIGHT, BACK+LEFT, BACK+RIGHT], 
                            anchor=BOTTOM);
            }

            //手柄内部两边增加0.5mm的凹槽，更好的固定pcb
            translate([handle_inner_width/2-0.5,0,0])
                pcb_solt(w=0.5,h=46);
            translate([-handle_inner_width/2,0,0])
                pcb_solt(w=0.5,h=46);


        }

        //屏幕挖槽
        //直接把屏幕宽度超出手柄，这样的槽方便屏幕插入
        translate([lcd_h/2,-(handle_inner_thickness/2-lcd_t+0.4)+0.001,lcd_off])
            tft_n099_display(w=50);
       // // 倒角
       // //translate([-lcd_h/2,-(handle_inner_thickness/2-lcd_t),lcd_off])
       // //    chamfer_screen();

       // //在外壳上挖出pcb部分槽
        c245_pcb();

        //正面螺丝孔
        color("red")
            translate([0,-handle_thickness/2-0.6,m1_6_fore])
            rotate([270,0,0])m1_6();

        //背部螺丝孔
        color("red")
            translate([0,handle_thickness/2+0.6,m1_6_back])
            rotate([90,0,0])m1_6();

    }


}




handle_top_length=2;
module handle_top(){
    color("blue")
        difference(){
            //顶部凸出外环，用于安装盖子
            cuboid([handle_width, handle_thickness,handle_top_length +0.2], 
                    rounding=corner_radius, 
                    edges=[FRONT+LEFT, FRONT+RIGHT, BACK+LEFT, BACK+RIGHT], 
                    anchor=BOTTOM);

            translate([0,0,-0.1])
                cuboid([handle_inner_width+2, handle_inner_thickness+2, handle_top_length+1], 
                        rounding=inner_corner_radius, 
                        edges=[FRONT+LEFT, FRONT+RIGHT, BACK+LEFT, BACK+RIGHT], 
                        anchor=BOTTOM);
        }
}

module handle_all(){
    union(){
        handle();

        //增加顶部外环
        translate([0,0,handle_length-0.1])
            handle_top();

        //底部螺纹孔
        bottom_screw_hole();
    }





}


module c245_top_panel(){

    difference(){
        union(){
            translate([0,0,pcb_w-0.001])
                cuboid([handle_inner_width+2, handle_inner_thickness+2, handle_top_length], 
                        rounding=inner_corner_radius, 
                        edges=[FRONT+LEFT, FRONT+RIGHT, BACK+LEFT, BACK+RIGHT], 
                        anchor=BOTTOM);
            translate([0,0,pcb_w-24])
                cuboid([handle_inner_width-0.1, handle_inner_thickness-0.1, 25], 
                        rounding=inner_corner_radius-0.05, 
                        edges=[FRONT+LEFT, FRONT+RIGHT, BACK+LEFT, BACK+RIGHT], 
                        anchor=BOTTOM);
            translate([lcd_h/2,-(handle_inner_thickness/2-lcd_t+0.4)-0.001,lcd_off+lcd_w])
                tft_n099_display(w=handle_length-lcd_off-lcd_w,show_screen=false);
        }
        c245_pcb();
        translate([-(handle_inner_width)/2,0,pcb_w-30])
            cuboid([handle_inner_width, handle_inner_thickness,30],anchor=LEFT+FRONT+BOTTOM);
            translate([lcd_h/2,-(handle_inner_thickness/2-lcd_t+0.4)-0.001,lcd_off])
            tft_n099_display(show_screen=false);

        translate([0, 0, m1_6_fore])
            rotate([90,0,0])cylinder(5,d=2.2);

        // 右边剩余少量边角，去除它
        translate([lcd_h/2-4,-(handle_inner_thickness/2-lcd_t+0.4)-2,lcd_off+0.1])
            cuboid([handle_inner_width, handle_inner_thickness+2,30],anchor=LEFT+FRONT+BOTTOM);
    }
}

//把键帽跟盖板组合在一起打印。
module gen_keycap_and_panel(){
    //rotate([0,180,0])
    translate([0,0,-pcb_w])
        c245_top_panel();

    translate([-2.5,-2,-15])
    rotate([90,90,0])
        union(){
            translate([-3.0,1,0])
                cylinder(2,d=2);
            translate([-3.0,1,1.9])
                keycap(fill=true);

            translate([3.0,1,0])
                cylinder(2,d=2);
            translate([3.0,1,1.9])
                keycap(fill=true);
        }
}

//底部M10螺纹孔，用于连接金属头
module bottom_screw_hole(){
    slop = 0.1;         // 螺纹间隙（3D 打印建议 0.1-0.2）
                        //


    translate([0,0,-ring_h+0.01])
        difference() {
            union(){
                hull(){
                    cyl(h=1, d=15,anchor=BOTTOM);

                    translate([0,0,transition_length])
                        cuboid([handle_width, handle_thickness, 0.01], 
                                rounding=corner_radius, 
                                edges=[FRONT+LEFT, FRONT+RIGHT, BACK+LEFT, BACK+RIGHT], 
                                anchor=BOTTOM);
                }

                translate([0,0,transition_length])
                    cuboid([handle_width, handle_thickness, ring_h-transition_length], 
                            rounding=corner_radius, 
                            edges=[FRONT+LEFT, FRONT+RIGHT, BACK+LEFT, BACK+RIGHT], 
                            anchor=BOTTOM);
            }

            // M10 内螺纹孔
            screw_hole(
                    "M10",             // M10 螺纹规格
                    length=ring_h + 0.1, // 螺纹深度略大于厚度
                    thread=true,       // 启用螺纹（内螺纹）
                    $slop=slop,        // 间隙
                    anchor=BOTTOM
                    );
        }
}

module bottom_header(){
    c_h = 8;  // 顶部螺丝圆柱高度
    c_d = 8;  // 
              //
    c1_h = 2;  // 中间凸起圆环
    c1_d = 15;  // 
                //
    c2_h = 9;       // 底部连接盖子圆环高度
    c2_d = 12;      // 圆柱直径
    //用于连接盖子的圆环
    module b2(){
        groove_width = 0.6;   // 凹槽宽度（Z 方向）
        groove_depth = 0.2;   // 凹槽深度（径向）
                              // 生成圆柱并切出凹槽
        difference() {
            // 计算凹槽中心 Z 坐标（居中分布）
            groove_centers = [1.8, 1.8+groove_width+1.8, 1.8+(groove_width+1.8)*2]; // 第一个凹槽中心 Z=3mm，间隔 1.5mm


            // 基本圆柱，底部对齐 Z=0
            cyl(d=c2_d,l=c2_h,chamfer1=0.1,center=false);

            // 循环生成 3 个矩形截面环形凹槽
            for (z = groove_centers) {
                translate([0, 0, z])
                    difference() {
                        // 外圆柱（切除区域）
                        cylinder(d=c2_d+0.02, h=groove_width);
                        // 内圆柱（保留凹槽底部）
                        cylinder(d=c2_d - 2*groove_depth, h=groove_width + 0.01);
                    }
            }
        }
    }
    difference(){
        union(){
            // 顶部 M10 外螺纹
            union() {
                thread_length = 7;  // 螺纹长度
                                    // 基本圆柱
                cylinder(d=c_d+0.4, h=c_h);

                translate([0, 0, thread_length/2+(c_h-thread_length)])
                    threaded_rod(d=10, h=thread_length, pitch=1.5,  internal=false);
            }
            //中间大圆环
            translate([0, 0, -c1_h])
                cyl(d=c1_d,l=c1_h,chamfer=0.1,center=false);

            translate([0, 0, -2-9])
                b2();
        }


        //削去内部空间
        union(){
            d=3.6;
            hull(){
                translate([0, 0, c_h])
                    cylinder(d=c_d-2, h=0.1);
                translate([0, 0, 4])
                    cylinder(d=c_d-2, h=0.1);
                translate([0, 0, 3])
                    cylinder(d=d, h=0.1);
            }
            hull(){
                translate([0, 0, 3])
                    cylinder(d=d, h=0.1);
                translate([0, 0, -3])
                    cylinder(d=d, h=0.1);
            }
            hull(){
                translate([0, 0, -3])
                    cylinder(d=d, h=0.1);
                translate([0, 0, -5])
                    cylinder(d=c2_d-2, h=0.1);
                translate([0, 0, -(c1_h+c2_h+0.1)])
                    cylinder(d=c2_d-2, h=0.1);
            }
        }
    }

}



// 控制圆等精度，预览时跳小减少渲染资源消耗，
// 最终生成模型时加大到100以上生成高精度模型
$fn=100;
//手柄主体部分
//handle_all();
//c245_pcb();

// 顶部盖子加按键帽一起方便打印，之后用小刀分离
gen_keycap_and_panel();

// 顶部盖子
//c245_top_panel();


// 底部金属头
//bottom_header();






