
// 引入BOSL2库
include <BOSL2/std.scad>
include <BOSL2/threading.scad>



// 参数定义
thread_diameter = 16;         // M16螺纹直径
thread_length = 7;          // 螺柱长度
nut_outer_diameter = 20;      // 螺帽外径
handle_width = 17;            // 手柄宽度（X方向）
handle_thickness = 14.5;        // 手柄厚度（Y方向）
handle_length = 99;          // 手柄主体长度
transition_length = 6;        // 过渡段长度
corner_radius = 6;            // 圆角半径（Z轴四棱）
                              //
handle_inner_width = 12;            // 手柄内部宽度（X方向）
handle_inner_thickness = 4.7*2+1.6;        // 手柄内部厚度 给弹片留出足够空间设为4.6mm,板厚1.6
inner_corner_radius = 4;            // 内部圆角半径（Z轴四棱）


//pcb尺寸信息
pcb_w=99+0.1;
pcb_h=13+0.3;
pcb_t=1.6+0.2;


//lcd外部轮廓，最大误差再额外增加0.1
lcd_h=8.6+0.1+0.1;
lcd_w=29.8+0.1+0.1;
lcd_t=1.5+0.1+0.05;

screen_h=6.00;//屏幕显示区域高度，比6.095稍微小些
screen_w=24.3;//屏幕显示区域宽度，比24.385小

module tft_n099_display(w=lcd_w,h=lcd_h,t=lcd_t,show_screen=true){
    //把lcd显示面移动旋转到面向Y轴负方向
    translate([0,0,w])
        rotate([0,90,-90])
        union(){
            //0.99寸tft屏幕，分辨率40*160
            //屏幕Z轴为厚度
            cube([w,h,t]);
            //x轴中心对齐
            if(show_screen){
                translate([1.4,(h-screen_h)/2,0])
                    color("blue") cube([screen_w,screen_h,15]);//可显示区域,厚度设置足够高方便验证屏幕区域是否被正确挖空
            }
        }
}

//
// 倒角模块（只针对显示区域）
module chamfer_screen() {
    //把lcd显示面移动旋转到面向Y轴负方向
    color("green") 
        translate([0,0,lcd_w])
        rotate([0,90,-90])
        hull(){
            //大于屏幕，在屏幕上一个手柄外壳的距离
            inc_w=6;
            inc_h=3;
            handle_shell_t=(handle_thickness-handle_inner_thickness)/2;
            translate([1.4-inc_w/2,(lcd_h-screen_h)/2-inc_h/2,lcd_t+handle_shell_t])
                cube([screen_w+inc_w,screen_h+inc_h,0.01]);

            translate([1.4,(lcd_h-screen_h)/2,lcd_t])
                cube([screen_w,screen_h,0.1]);
        }
}

module keycap(key_h=2.5,key_d=3,fill=true) {
    difference() {
        union() {
            cyl(h=1.2, d=key_d+2,anchor=BOTTOM);
            translate([0, 0, 1.2])
                cyl(h=key_h, d=key_d, rounding2=0.5,anchor=BOTTOM); // 顶部圆角
        }
        if(!fill){
            cyl(h=key_h, d=1.5,anchor=BOTTOM);
        }
    }
}

//按键小板
// 默认尺寸
function t12_key_pcb_dims(width=17+0.1, height=10+0.1, thickness=1+0.1) = [
    width,
    height,
    thickness
];
module t12_key_pcb(){
    dims=t12_key_pcb_dims();
    pcb2_w=dims[0];
    pcb2_h=dims[1];
    pcb2_t=dims[2];
    //y轴中心
    color("green")cube([pcb2_w,pcb2_h,pcb2_t]);
    //C388295按键,按键高度根据型号调整
    module key(){
        //使用键帽进行diff,增加余量保证顺畅按压
        //按键半径比实际大0.05
        color("red")
            //按键1.5mm
            translate([0,0,1.5+0.3])
            keycap(key_d=3.1);
        rotate([0,0,-90]){
            translate([-2.7,-3.2,0])
                cube([5.2,6.4,1.2]);

        }
    }
    //key1
    translate([4,pcb2_h/2,1])
        key();
    //key2
    translate([13,pcb2_h/2,1])
        key();

}

//pcb
module t12_pcb(){
    difference(){
        cube([pcb_w,pcb_h,pcb_t]);
        t12_w=57;
        t12_h=6;
        translate([0,(pcb_h-t12_h)/2,0])
            color("red")cube([t12_w,t12_h,pcb_t]);
    }

    //按键小板焊接在主pcb的x轴的38位置,沿y轴中心对齐
    //往z轴上方偏移，保证t12烙铁头能插入，且按键能被按

    pcb2_t_off=handle_inner_thickness/2-(1.4+t12_key_pcb_dims()[2]);//按键有1.5,让键帽嵌入外壳部分
    translate([38,(pcb_h-t12_key_pcb_dims()[1])/2,pcb2_t_off])
        t12_key_pcb();
}


module pcb_solt(t=1,w=1,h=35){
    rotate([0,0,90])
        union(){
            translate([-t-pcb_t/2,0,0])
                cube([t,w,h]);

            translate([pcb_t/2,0,0])
                cube([t,w,h]);
        }
}

//lcd相对于手柄底部的位置
lcd_off=58;


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

        //屏幕挖槽
        translate([-lcd_h/2,-(handle_inner_thickness/2-lcd_t),lcd_off])
            tft_n099_display();
        // 倒角
        translate([-lcd_h/2,-(handle_inner_thickness/2-lcd_t),lcd_off])
            chamfer_screen();
        //直接把屏幕宽度超出手柄，这样的槽方便屏幕插入
        translate([-lcd_h/2,-(handle_inner_thickness/2-lcd_t),lcd_off])
            tft_n099_display(w=50,show_screen=false);

        //在外壳上挖出pcb部分槽
        translate([pcb_h/2,pcb_t/2,0])
            rotate([0,-90,90])
            t12_pcb();

        //正面螺丝孔
        color("red")
            translate([0,-handle_thickness/2-0.5,96])
            rotate([-90,0,0])m1_6();

        //背部螺丝孔
        color("red")
            translate([0,handle_thickness/2+0.5,59])
            rotate([90,0,0])m1_6();


    }

    //手柄内部两边增加0.5mm的凹槽，更好的固定pcb
    translate([handle_inner_width/2,0,0])
        pcb_solt(w=0.5,h=handle_length);
    translate([-handle_inner_width/2+0.5,0,0])
        pcb_solt(w=0.5,h=handle_length);

    //手柄下部可以把凹槽增大到1mm覆盖原本的0.5mm凹槽,高度为58mm
    translate([handle_inner_width/2,0,0])
        pcb_solt(w=1,h=58);
    translate([-handle_inner_width/2+1,0,0])
        pcb_solt(w=1,h=58);




}


thread_pitch = 1;       // 螺距 1mm
                        // M16 螺柱
module m16_stud() {
    threaded_rod(
            d = thread_diameter,
            l = thread_length+0.1,
            pitch = thread_pitch,
            anchor = BOTTOM
            );
}


//底部跟头套螺纹连接处，以及过渡到手柄的过渡区
module t12_buttom_header(){
    difference(){
        union(){
            hull(){
                cuboid([handle_width, handle_thickness, 0.1], 
                        rounding=corner_radius, 
                        edges=[FRONT+LEFT, FRONT+RIGHT, BACK+LEFT, BACK+RIGHT], 
                        anchor=BOTTOM);
                translate([0, 0, - transition_length])
                    cylinder(0.1,d=nut_outer_diameter);
            }
            translate([0, 0, -thread_length - transition_length]) m16_stud();
        }
        //稍微大于螺帽跟过渡区长度，diff预览效果好
        translate([0, 0, -thread_length - transition_length-0.1])
            cylinder(13.5,d=10);

        //把螺柱圆环切除部分，为了更好适配头套
        translate([-thread_diameter/2, -pcb_t/2, -thread_length-transition_length])
            cube([thread_diameter,pcb_t,thread_length]);
    }
}


handle_top_length=1.6;
module t12_top(){
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

module t12_handle_all(){
    union(){
        t12_buttom_header();
        handle();

        //增加顶部外环
        translate([0,0,handle_length-0.1])
            t12_top();
    }
    //translate([pcb_h/2,pcb_t/2,0])
    //rotate([0,-90,90])
    //    t12_pcb();



    //translate([50-lcd_h/2,-(handle_inner_thickness/2-lcd_t),lcd_off])
    //    tft_n099_display();


}


module t12_top_panel(){

    difference(){
        cuboid([handle_inner_width+2, handle_inner_thickness+2, handle_top_length], 
                rounding=inner_corner_radius, 
                edges=[FRONT+LEFT, FRONT+RIGHT, BACK+LEFT, BACK+RIGHT], 
                anchor=BOTTOM);

        // Type-C 尺寸
        typec_width = 8.94+0.1;  // X 轴
        typec_thickness = 3.16+0.1;  // Y 轴
        typec_height = 3; //长度比上盖厚度大就行，保证可以完成打孔 

        translate([0, typec_thickness/2+pcb_t/2, -0.1])
            color("red")cuboid([typec_width, typec_thickness, typec_height],
                    rounding=1.5,
                    edges=[FRONT+LEFT, FRONT+RIGHT, BACK+LEFT, BACK+RIGHT],
                    anchor=BOTTOM);
    }

    t=2;
    translate([0,-(handle_inner_thickness/2-t)-t/2+0.1, 0])//不要紧贴屏幕槽
        difference(){
            union(){
                cuboid([lcd_h, t, 6],
                        rounding=2,
                        edges=[ BOTTOM+LEFT, BOTTOM+RIGHT],
                        anchor=TOP);
                // 左三角形加强筋
                translate([-3, 0, 0]) // X=-4
                    hull() {
                        translate([0, 0, -0.1]) cube([1, 0.1, 0.1]); 
                        translate([0, 3, -0.1]) cube([1, 0.1, 0.1]); 
                        translate([0, 0, -4]) cube([1, 0.1, 0.1]); 
                    }
                // 右三角形加强筋
                translate([2, 0, 0]) // X=2
                    hull() {
                        translate([0, 0, -0.1]) cube([1, 0.1, 0.1]); 
                        translate([0, 3, -0.1]) cube([1, 0.1, 0.1]); 
                        translate([0, 0, -4]) cube([1, 0.1, 0.1]); 
                    }
            }
            translate([0, 1.3, -3])
                rotate([90,0,0])cylinder(2.5,d=2.2);
        }
}

//把键帽跟盖板组合在一起打印。
module gen_keycap_and_panel(){
    rotate([0,180,0])
        t12_top_panel();

    translate([-5.5,0,0])
        cylinder(2,d=2);
    translate([-5.5,0,2])
        keycap(fill=false);

    translate([5.5,0,0])
        cylinder(2,d=2);
    translate([5.5,0,2])
        keycap(fill=false);

}

// 键帽和顶部盖子一起方便打印
//gen_keycap_and_panel();

$fn=100;

t12_handle_all();
//t12_top_panel();

