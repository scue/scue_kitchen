#!/bin/bash
# Version: 0.1
# Author: linkscue
# E-Mail: linkscue@gmail.com
# Function: change android.policy.jar & framework.jar (ICS only)

# check files
if [[ ! -e android.policy.jar || ! -e framework.jar ]]; then
    echo "Please put android.policy.jar & framework.jar here!"
    exit 1
fi

# check java 
if [[ -n `java -version` ]]; then
    echo "Java didn't installed in your pc!"
    exit 1
fi

# tmp dir
tdir=./tmp_$$
if [[ ! -d $tdir ]]; then
    mkdir $tdir
fi

#command shorted
smali(){
    java -jar ./smali/smali-1.4.1.jar $1 $2 $3 
}
baksmali(){
    java -jar ./smali/baksmali-1.4.1.jar $1 $2 $3
}

# unzip jar file
framework_dir=$tdir/framework_dir
android_policy_dir=$tdir/android.policy_dir
if [[ ! -d ${android_policy_dir} ]]; then
    unzip android.policy.jar -d ${android_policy_dir}
fi
if [[ ! -d $framework_dir ]]; then
    unzip framework.jar -d $framework_dir
fi

# cp the classes.dex file
classes_policy=$tdir/classes_policy.dex
classes_framework=$tdir/classes_framework.dex
cp $android_policy_dir/classes.dex $classes_policy
cp $framework_dir/classes.dex $classes_framework

# decode dex file 
c_p_dir=$tdir/out_policy_dir
c_f_dir=$tdir/out_framework_dir
if [[ ! -d $c_p_dir ]]; then
    baksmali $classes_policy -o $c_p_dir   
fi
if [[ ! -d $c_f_dir ]]; then
    baksmali $classes_framework -o $c_f_dir
fi

# write the modified code
code=$tdir/code.txt
cat << EOF > $code
.method refreshDate()V
    .registers 6

    .prologue
    .line 889
    iget-object v1, p0, Lcom/android/internal/policy/impl/KeyguardStatusViewManager;->mDateView:Landroid/widget/TextView;

    if-eqz v1, :cond_42

    .line 890
    new-instance v0, Ljava/util/Date;

    invoke-direct {v0}, Ljava/util/Date;-><init>()V

    .line 891
    .local v0, now:Ljava/util/Date;
    invoke-virtual {v0}, Ljava/util/Date;->getYear()I

    move-result v1

    add-int/lit16 v1, v1, 0x76c

    invoke-virtual {v0}, Ljava/util/Date;->getMonth()I

    move-result v2

    invoke-virtual {v0}, Ljava/util/Date;->getDate()I

    move-result v3

    invoke-static {v1, v2, v3}, Landroid/util/Lunar;->setLunar(III)V

    .line 892
    iget-object v1, p0, Lcom/android/internal/policy/impl/KeyguardStatusViewManager;->mDateView:Landroid/widget/TextView;

    new-instance v2, Ljava/lang/StringBuilder;

    invoke-direct {v2}, Ljava/lang/StringBuilder;-><init>()V

    iget-object v3, p0, Lcom/android/internal/policy/impl/KeyguardStatusViewManager;->mDateFormatString:Ljava/lang/String;

    invoke-static {v3, v0}, Landroid/text/format/DateFormat;->format(Ljava/lang/CharSequence;Ljava/util/Date;)Ljava/lang/CharSequence;

    move-result-object v3

    invoke-virtual {v2, v3}, Ljava/lang/StringBuilder;->append(Ljava/lang/Object;)Ljava/lang/StringBuilder;

    move-result-object v2

    const-string v3, " "

    invoke-virtual {v2, v3}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v2

    const/4 v3, 0x5

    const/4 v4, 0x0

    invoke-static {v3, v4}, Landroid/util/Lunar;->getLunar(IZ)Ljava/lang/String;

    move-result-object v3

    invoke-virtual {v2, v3}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v2

    invoke-virtual {v2}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v2

    invoke-virtual {v1, v2}, Landroid/widget/TextView;->setText(Ljava/lang/CharSequence;)V

    .line 894
    .end local v0           #now:Ljava/util/Date;
    :cond_42
    return-void
.end method
EOF

# write Lunar.smali file
Lunar=$c_f_dir/android/util/Lunar.smali
cat << EOF > $Lunar
.class public Landroid/util/Lunar;
.super Ljava/lang/Object;
.source "Lunar.java"



# static fields
.field private static day:I

.field private static isLeap:Z

.field private static isSetShowLunch:Z

.field private static isShowLunch:Z

.field private static lunarInfo:[I

.field private static month:I

.field private static monthNong:[Ljava/lang/String;

.field private static nStr1:[Ljava/lang/String;

.field private static nStr2:[Ljava/lang/String;

.field private static solarTerm:Ljava/lang/String;

.field private static solarTerms:[Ljava/lang/String;

.field private static termInfo:[I

.field private static year:I



# direct methods
.method static constructor <clinit>()V
    .registers 8

    .prologue
    const/4 v7, 0x4

    const/4 v6, 0x3

    const/4 v5, 0x2

    const/4 v4, 0x1

    const/4 v3, 0x0

    .line 13
    sput-boolean v3, Landroid/util/Lunar;->isSetShowLunch:Z

    .line 14
    const/16 v0, 0x96

    new-array v0, v0, [I

    fill-array-data v0, :array_174

    sput-object v0, Landroid/util/Lunar;->lunarInfo:[I

    .line 36
    const/16 v0, 0x18

    new-array v0, v0, [I

    fill-array-data v0, :array_2a4

    sput-object v0, Landroid/util/Lunar;->termInfo:[I

    .line 42
    const/16 v0, 0x18

    new-array v0, v0, [Ljava/lang/String;

    const-string/jumbo v1, "\u5c0f\u5bd2"

    aput-object v1, v0, v3

    const-string/jumbo v1, "\u5927\u5bd2"

    aput-object v1, v0, v4

    const-string/jumbo v1, "\u7acb\u6625"

    aput-object v1, v0, v5

    const-string/jumbo v1, "\u96e8\u6c34"

    aput-object v1, v0, v6

    const-string/jumbo v1, "\u60ca\u86f0"

    aput-object v1, v0, v7

    const/4 v1, 0x5

    const-string/jumbo v2, "\u6625\u5206"

    aput-object v2, v0, v1

    const/4 v1, 0x6

    const-string/jumbo v2, "\u6e05\u660e"

    aput-object v2, v0, v1

    const/4 v1, 0x7

    const-string/jumbo v2, "\u8c37\u96e8"

    aput-object v2, v0, v1

    const/16 v1, 0x8

    const-string/jumbo v2, "\u7acb\u590f"

    aput-object v2, v0, v1

    const/16 v1, 0x9

    const-string/jumbo v2, "\u5c0f\u6ee1"

    aput-object v2, v0, v1

    const/16 v1, 0xa

    const-string/jumbo v2, "\u8292\u79cd"

    aput-object v2, v0, v1

    const/16 v1, 0xb

    const-string/jumbo v2, "\u590f\u81f3"

    aput-object v2, v0, v1

    const/16 v1, 0xc

    const-string/jumbo v2, "\u5c0f\u6691"

    aput-object v2, v0, v1

    const/16 v1, 0xd

    const-string/jumbo v2, "\u5927\u6691"

    aput-object v2, v0, v1

    const/16 v1, 0xe

    const-string/jumbo v2, "\u7acb\u79cb"

    aput-object v2, v0, v1

    const/16 v1, 0xf

    const-string/jumbo v2, "\u5904\u6691"

    aput-object v2, v0, v1

    const/16 v1, 0x10

    const-string/jumbo v2, "\u767d\u9732"

    aput-object v2, v0, v1

    const/16 v1, 0x11

    const-string/jumbo v2, "\u79cb\u5206"

    aput-object v2, v0, v1

    const/16 v1, 0x12

    const-string/jumbo v2, "\u5bd2\u9732"

    aput-object v2, v0, v1

    const/16 v1, 0x13

    const-string/jumbo v2, "\u971c\u964d"

    aput-object v2, v0, v1

    const/16 v1, 0x14

    const-string/jumbo v2, "\u7acb\u51ac"

    aput-object v2, v0, v1

    const/16 v1, 0x15

    const-string/jumbo v2, "\u5c0f\u96ea"

    aput-object v2, v0, v1

    const/16 v1, 0x16

    const-string/jumbo v2, "\u5927\u96ea"

    aput-object v2, v0, v1

    const/16 v1, 0x17

    const-string/jumbo v2, "\u51ac\u81f3"

    aput-object v2, v0, v1

    sput-object v0, Landroid/util/Lunar;->solarTerms:[Ljava/lang/String;

    .line 48
    const/16 v0, 0xb

    new-array v0, v0, [Ljava/lang/String;

    const-string/jumbo v1, "\u65e5"

    aput-object v1, v0, v3

    const-string/jumbo v1, "\u4e00"

    aput-object v1, v0, v4

    const-string/jumbo v1, "\u4e8c"

    aput-object v1, v0, v5

    const-string/jumbo v1, "\u4e09"

    aput-object v1, v0, v6

    const-string/jumbo v1, "\u56db"

    aput-object v1, v0, v7

    const/4 v1, 0x5

    const-string/jumbo v2, "\u4e94"

    aput-object v2, v0, v1

    const/4 v1, 0x6

    const-string/jumbo v2, "\u516d"

    aput-object v2, v0, v1

    const/4 v1, 0x7

    const-string/jumbo v2, "\u4e03"

    aput-object v2, v0, v1

    const/16 v1, 0x8

    const-string/jumbo v2, "\u516b"

    aput-object v2, v0, v1

    const/16 v1, 0x9

    const-string/jumbo v2, "\u4e5d"

    aput-object v2, v0, v1

    const/16 v1, 0xa

    const-string/jumbo v2, "\u5341"

    aput-object v2, v0, v1

    sput-object v0, Landroid/util/Lunar;->nStr1:[Ljava/lang/String;

    .line 51
    const/4 v0, 0x5

    new-array v0, v0, [Ljava/lang/String;

    const-string/jumbo v1, "\u521d"

    aput-object v1, v0, v3

    const-string/jumbo v1, "\u5341"

    aput-object v1, v0, v4

    const-string/jumbo v1, "\u5eff"

    aput-object v1, v0, v5

    const-string/jumbo v1, "\u5345"

    aput-object v1, v0, v6

    const-string/jumbo v1, "\u3000"

    aput-object v1, v0, v7

    sput-object v0, Landroid/util/Lunar;->nStr2:[Ljava/lang/String;

    .line 53
    const/16 v0, 0xd

    new-array v0, v0, [Ljava/lang/String;

    const-string/jumbo v1, "\u6b63"

    aput-object v1, v0, v3

    const-string/jumbo v1, "\u6b63"

    aput-object v1, v0, v4

    const-string/jumbo v1, "\u4e8c"

    aput-object v1, v0, v5

    const-string/jumbo v1, "\u4e09"

    aput-object v1, v0, v6

    const-string/jumbo v1, "\u56db"

    aput-object v1, v0, v7

    const/4 v1, 0x5

    const-string/jumbo v2, "\u4e94"

    aput-object v2, v0, v1

    const/4 v1, 0x6

    const-string/jumbo v2, "\u516d"

    aput-object v2, v0, v1

    const/4 v1, 0x7

    const-string/jumbo v2, "\u4e03"

    aput-object v2, v0, v1

    const/16 v1, 0x8

    const-string/jumbo v2, "\u516b"

    aput-object v2, v0, v1

    const/16 v1, 0x9

    const-string/jumbo v2, "\u4e5d"

    aput-object v2, v0, v1

    const/16 v1, 0xa

    const-string/jumbo v2, "\u5341"

    aput-object v2, v0, v1

    const/16 v1, 0xb

    const-string/jumbo v2, "\u5341\u4e00"

    aput-object v2, v0, v1

    const/16 v1, 0xc

    const-string/jumbo v2, "\u5341\u4e8c"

    aput-object v2, v0, v1

    sput-object v0, Landroid/util/Lunar;->monthNong:[Ljava/lang/String;

    return-void

    .line 14
    nop

    :array_174
    .array-data 0x4
         0xd8t 0x4bt 0x0t 0x0t
         0xe0t 0x4at 0x0t 0x0t
         0x70t 0xa5t 0x0t 0x0t
         0xd5t 0x54t 0x0t 0x0t
         0x60t 0xd2t 0x0t 0x0t
         0x50t 0xd9t 0x0t 0x0t
         0x54t 0x65t 0x1t 0x0t
         0xa0t 0x56t 0x0t 0x0t
         0xd0t 0x9at 0x0t 0x0t
         0xd2t 0x55t 0x0t 0x0t
         0xe0t 0x4at 0x0t 0x0t
         0xb6t 0xa5t 0x0t 0x0t
         0xd0t 0xa4t 0x0t 0x0t
         0x50t 0xd2t 0x0t 0x0t
         0x55t 0xd2t 0x1t 0x0t
         0x40t 0xb5t 0x0t 0x0t
         0xa0t 0xd6t 0x0t 0x0t
         0xa2t 0xadt 0x0t 0x0t
         0xb0t 0x95t 0x0t 0x0t
         0x77t 0x49t 0x1t 0x0t
         0x70t 0x49t 0x0t 0x0t
         0xb0t 0xa4t 0x0t 0x0t
         0xb5t 0xb4t 0x0t 0x0t
         0x50t 0x6at 0x0t 0x0t
         0x40t 0x6dt 0x0t 0x0t
         0x54t 0xabt 0x1t 0x0t
         0x60t 0x2bt 0x0t 0x0t
         0x70t 0x95t 0x0t 0x0t
         0xf2t 0x52t 0x0t 0x0t
         0x70t 0x49t 0x0t 0x0t
         0x66t 0x65t 0x0t 0x0t
         0xa0t 0xd4t 0x0t 0x0t
         0x50t 0xeat 0x0t 0x0t
         0x95t 0x6et 0x0t 0x0t
         0xd0t 0x5at 0x0t 0x0t
         0x60t 0x2bt 0x0t 0x0t
         0xe3t 0x86t 0x1t 0x0t
         0xe0t 0x92t 0x0t 0x0t
         0xd7t 0xc8t 0x1t 0x0t
         0x50t 0xc9t 0x0t 0x0t
         0xa0t 0xd4t 0x0t 0x0t
         0xa6t 0xd8t 0x1t 0x0t
         0x50t 0xb5t 0x0t 0x0t
         0xa0t 0x56t 0x0t 0x0t
         0xb4t 0xa5t 0x1t 0x0t
         0xd0t 0x25t 0x0t 0x0t
         0xd0t 0x92t 0x0t 0x0t
         0xb2t 0xd2t 0x0t 0x0t
         0x50t 0xa9t 0x0t 0x0t
         0x57t 0xb5t 0x0t 0x0t
         0xa0t 0x6ct 0x0t 0x0t
         0x50t 0xb5t 0x0t 0x0t
         0x55t 0x53t 0x1t 0x0t
         0xa0t 0x4dt 0x0t 0x0t
         0xd0t 0xa5t 0x0t 0x0t
         0x73t 0x45t 0x1t 0x0t
         0xd0t 0x52t 0x0t 0x0t
         0xa8t 0xa9t 0x0t 0x0t
         0x50t 0xe9t 0x0t 0x0t
         0xa0t 0x6at 0x0t 0x0t
         0xa6t 0xaet 0x0t 0x0t
         0x50t 0xabt 0x0t 0x0t
         0x60t 0x4bt 0x0t 0x0t
         0xe4t 0xaat 0x0t 0x0t
         0x70t 0xa5t 0x0t 0x0t
         0x60t 0x52t 0x0t 0x0t
         0x63t 0xf2t 0x0t 0x0t
         0x50t 0xd9t 0x0t 0x0t
         0x57t 0x5bt 0x0t 0x0t
         0xa0t 0x56t 0x0t 0x0t
         0xd0t 0x96t 0x0t 0x0t
         0xd5t 0x4dt 0x0t 0x0t
         0xd0t 0x4at 0x0t 0x0t
         0xd0t 0xa4t 0x0t 0x0t
         0xd4t 0xd4t 0x0t 0x0t
         0x50t 0xd2t 0x0t 0x0t
         0x58t 0xd5t 0x0t 0x0t
         0x40t 0xb5t 0x0t 0x0t
         0xa0t 0xb5t 0x0t 0x0t
         0xa6t 0x95t 0x1t 0x0t
         0xb0t 0x95t 0x0t 0x0t
         0xb0t 0x49t 0x0t 0x0t
         0x74t 0xa9t 0x0t 0x0t
         0xb0t 0xa4t 0x0t 0x0t
         0x7at 0xb2t 0x0t 0x0t
         0x50t 0x6at 0x0t 0x0t
         0x40t 0x6dt 0x0t 0x0t
         0x46t 0xaft 0x0t 0x0t
         0x60t 0xabt 0x0t 0x0t
         0x70t 0x95t 0x0t 0x0t
         0xf5t 0x4at 0x0t 0x0t
         0x70t 0x49t 0x0t 0x0t
         0xb0t 0x64t 0x0t 0x0t
         0xa3t 0x74t 0x0t 0x0t
         0x50t 0xeat 0x0t 0x0t
         0x58t 0x6bt 0x0t 0x0t
         0xc0t 0x55t 0x0t 0x0t
         0x60t 0xabt 0x0t 0x0t
         0xd5t 0x96t 0x0t 0x0t
         0xe0t 0x92t 0x0t 0x0t
         0x60t 0xc9t 0x0t 0x0t
         0x54t 0xd9t 0x0t 0x0t
         0xa0t 0xd4t 0x0t 0x0t
         0x50t 0xdat 0x0t 0x0t
         0x52t 0x75t 0x0t 0x0t
         0xa0t 0x56t 0x0t 0x0t
         0xb7t 0xabt 0x0t 0x0t
         0xd0t 0x25t 0x0t 0x0t
         0xd0t 0x92t 0x0t 0x0t
         0xb5t 0xcat 0x0t 0x0t
         0x50t 0xa9t 0x0t 0x0t
         0xa0t 0xb4t 0x0t 0x0t
         0xa4t 0xbat 0x0t 0x0t
         0x50t 0xadt 0x0t 0x0t
         0xd9t 0x55t 0x0t 0x0t
         0xa0t 0x4bt 0x0t 0x0t
         0xb0t 0xa5t 0x0t 0x0t
         0x76t 0x51t 0x1t 0x0t
         0xb0t 0x52t 0x0t 0x0t
         0x30t 0xa9t 0x0t 0x0t
         0x54t 0x79t 0x0t 0x0t
         0xa0t 0x6at 0x0t 0x0t
         0x50t 0xadt 0x0t 0x0t
         0x52t 0x5bt 0x0t 0x0t
         0x60t 0x4bt 0x0t 0x0t
         0xe6t 0xa6t 0x0t 0x0t
         0xe0t 0xa4t 0x0t 0x0t
         0x60t 0xd2t 0x0t 0x0t
         0x65t 0xeat 0x0t 0x0t
         0x30t 0xd5t 0x0t 0x0t
         0xa0t 0x5at 0x0t 0x0t
         0xa3t 0x76t 0x0t 0x0t
         0xd0t 0x96t 0x0t 0x0t
         0xd7t 0x4bt 0x0t 0x0t
         0xd0t 0x4at 0x0t 0x0t
         0xd0t 0xa4t 0x0t 0x0t
         0xb6t 0xd0t 0x1t 0x0t
         0x50t 0xd2t 0x0t 0x0t
         0x20t 0xd5t 0x0t 0x0t
         0x45t 0xddt 0x0t 0x0t
         0xa0t 0xb5t 0x0t 0x0t
         0xd0t 0x56t 0x0t 0x0t
         0xb2t 0x55t 0x0t 0x0t
         0xb0t 0x49t 0x0t 0x0t
         0x77t 0xa5t 0x0t 0x0t
         0xb0t 0xa4t 0x0t 0x0t
         0x50t 0xaat 0x0t 0x0t
         0x55t 0xb2t 0x1t 0x0t
         0x20t 0x6dt 0x0t 0x0t
         0xa0t 0xadt 0x0t 0x0t
    .end array-data

    .line 36
    :array_2a4
    .array-data 0x4
         0x0t 0x0t 0x0t 0x0t
         0xd8t 0x52t 0x0t 0x0t
         0xe3t 0xa5t 0x0t 0x0t
         0x5ct 0xf9t 0x0t 0x0t
         0x59t 0x4dt 0x1t 0x0t
         0x6t 0xa2t 0x1t 0x0t
         0x63t 0xf7t 0x1t 0x0t
         0x89t 0x4dt 0x2t 0x0t
         0x5dt 0xa4t 0x2t 0x0t
         0xdft 0xfbt 0x2t 0x0t
         0xd8t 0x53t 0x3t 0x0t
         0x35t 0xact 0x3t 0x0t
         0xaft 0x4t 0x4t 0x0t
         0x25t 0x5dt 0x4t 0x0t
         0x53t 0xb5t 0x4t 0x0t
         0x19t 0xdt 0x5t 0x0t
         0x46t 0x64t 0x5t 0x0t
         0xc6t 0xbat 0x5t 0x0t
         0x87t 0x10t 0x6t 0x0t
         0x8at 0x65t 0x6t 0x0t
         0xdbt 0xb9t 0x6t 0x0t
         0x90t 0xdt 0x7t 0x0t
         0xcct 0x60t 0x7t 0x0t
         0xb6t 0xb3t 0x7t 0x0t
    .end array-data
.end method

.method public constructor <init>()V
    .registers 1

    .prologue
    .line 5
    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    return-void
.end method

.method private static ChineseTwentyFourDay(III)Ljava/lang/String;
    .registers 15
    .parameter "year"
    .parameter "month"
    .parameter "day"

    .prologue
    const/16 v6, 0x8

    const/4 v3, 0x6

    const/16 v4, 0x16

    const/4 v5, 0x5

    const/4 v2, 0x7

    .line 271
    add-int/lit8 p1, p1, 0x1

    .line 272
    const/4 v8, -0x1

    .line 273
    .local v8, index:I
    const/4 v1, 0x1

    if-ne p1, v1, :cond_58

    .line 274
    if-lt p2, v5, :cond_4e

    if-gt p2, v2, :cond_4e

    .line 275
    const/4 v8, 0x0

    .line 345
    :cond_12
    :goto_12
    const-string v11, ""

    .line 346
    .local v11, tempStr:Ljava/lang/String;
    const/4 v1, -0x1

    if-eq v8, v1, :cond_4d

    .line 347
    invoke-static {}, Ljava/util/Calendar;->getInstance()Ljava/util/Calendar;

    move-result-object v0

    .line 348
    .local v0, cal:Ljava/util/Calendar;
    const/16 v1, 0x76c

    const/4 v2, 0x0

    const/4 v4, 0x2

    const/4 v6, 0x0

    invoke-virtual/range {v0 .. v6}, Ljava/util/Calendar;->set(IIIIII)V

    .line 349
    const-wide v1, 0x41200cf9851eb852L

    add-int/lit16 v3, p0, -0x76c

    int-to-double v3, v3

    mul-double/2addr v1, v3

    sget-object v3, Landroid/util/Lunar;->termInfo:[I

    aget v3, v3, v8

    int-to-double v3, v3

    add-double v9, v1, v3

    .line 350
    .local v9, num:D
    const/16 v1, 0xc

    invoke-static {v9, v10}, Ljava/lang/Math;->ceil(D)D

    move-result-wide v2

    double-to-int v2, v2

    add-int/lit8 v2, v2, 0x5

    invoke-virtual {v0, v1, v2}, Ljava/util/Calendar;->add(II)V

    .line 351
    invoke-virtual {v0}, Ljava/util/Calendar;->getTime()Ljava/util/Date;

    move-result-object v7

    .line 352
    .local v7, bd:Ljava/util/Date;
    invoke-virtual {v7}, Ljava/util/Date;->getDate()I

    move-result v1

    if-ne v1, p2, :cond_4d

    .line 353
    sget-object v1, Landroid/util/Lunar;->solarTerms:[Ljava/lang/String;

    aget-object v11, v1, v8

    .line 355
    .end local v0       #cal:Ljava/util/Calendar;,
    .end local v7       #bd:Ljava/util/Date;,
    .end local v9       #num:D,
    :cond_4d
    return-object v11

    .line 276
    .end local v11       #tempStr:Ljava/lang/String;,
    :cond_4e
    const/16 v1, 0x14

    if-lt p2, v1, :cond_12

    const/16 v1, 0x15

    if-gt p2, v1, :cond_12

    .line 277
    const/4 v8, 0x1

    goto :goto_12

    .line 279
    :cond_58
    const/4 v1, 0x2

    if-ne p1, v1, :cond_6c

    .line 280
    const/4 v1, 0x3

    if-lt p2, v1, :cond_62

    if-gt p2, v5, :cond_62

    .line 281
    const/4 v8, 0x2

    goto :goto_12

    .line 282
    :cond_62
    const/16 v1, 0x12

    if-lt p2, v1, :cond_12

    const/16 v1, 0x14

    if-gt p2, v1, :cond_12

    .line 283
    const/4 v8, 0x3

    goto :goto_12

    .line 285
    :cond_6c
    const/4 v1, 0x3

    if-ne p1, v1, :cond_7d

    .line 286
    if-lt p2, v5, :cond_75

    if-gt p2, v2, :cond_75

    .line 287
    const/4 v8, 0x4

    goto :goto_12

    .line 288
    :cond_75
    const/16 v1, 0x14

    if-lt p2, v1, :cond_12

    if-gt p2, v4, :cond_12

    .line 289
    const/4 v8, 0x5

    goto :goto_12

    .line 291
    :cond_7d
    const/4 v1, 0x4

    if-ne p1, v1, :cond_91

    .line 292
    const/4 v1, 0x4

    if-lt p2, v1, :cond_87

    if-gt p2, v3, :cond_87

    .line 293
    const/4 v8, 0x6

    goto :goto_12

    .line 294
    :cond_87
    const/16 v1, 0x13

    if-lt p2, v1, :cond_12

    const/16 v1, 0x15

    if-gt p2, v1, :cond_12

    .line 295
    const/4 v8, 0x7

    goto :goto_12

    .line 297
    :cond_91
    if-ne p1, v5, :cond_a5

    .line 298
    if-lt p2, v5, :cond_9b

    if-gt p2, v2, :cond_9b

    .line 299
    const/16 v8, 0x8

    goto/16 :goto_12

    .line 300
    :cond_9b
    const/16 v1, 0x14

    if-lt p2, v1, :cond_12

    if-gt p2, v4, :cond_12

    .line 301
    const/16 v8, 0x9

    goto/16 :goto_12

    .line 303
    :cond_a5
    if-ne p1, v3, :cond_b9

    .line 304
    if-lt p2, v5, :cond_af

    if-gt p2, v2, :cond_af

    .line 305
    const/16 v8, 0xa

    goto/16 :goto_12

    .line 306
    :cond_af
    const/16 v1, 0x15

    if-lt p2, v1, :cond_12

    if-gt p2, v4, :cond_12

    .line 307
    const/16 v8, 0xb

    goto/16 :goto_12

    .line 309
    :cond_b9
    if-ne p1, v2, :cond_cd

    .line 310
    if-lt p2, v3, :cond_c3

    if-gt p2, v6, :cond_c3

    .line 311
    const/16 v8, 0xc

    goto/16 :goto_12

    .line 312
    :cond_c3
    if-lt p2, v4, :cond_12

    const/16 v1, 0x18

    if-gt p2, v1, :cond_12

    .line 313
    const/16 v8, 0xd

    goto/16 :goto_12

    .line 315
    :cond_cd
    if-ne p1, v6, :cond_e3

    .line 316
    if-lt p2, v2, :cond_d9

    const/16 v1, 0x9

    if-gt p2, v1, :cond_d9

    .line 317
    const/16 v8, 0xe

    goto/16 :goto_12

    .line 318
    :cond_d9
    if-lt p2, v4, :cond_12

    const/16 v1, 0x18

    if-gt p2, v1, :cond_12

    .line 319
    const/16 v8, 0xf

    goto/16 :goto_12

    .line 321
    :cond_e3
    const/16 v1, 0x9

    if-ne p1, v1, :cond_fb

    .line 322
    if-lt p2, v2, :cond_f1

    const/16 v1, 0x9

    if-gt p2, v1, :cond_f1

    .line 323
    const/16 v8, 0x10

    goto/16 :goto_12

    .line 324
    :cond_f1
    if-lt p2, v4, :cond_12

    const/16 v1, 0x18

    if-gt p2, v1, :cond_12

    .line 325
    const/16 v8, 0x11

    goto/16 :goto_12

    .line 327
    :cond_fb
    const/16 v1, 0xa

    if-ne p1, v1, :cond_115

    .line 328
    if-lt p2, v6, :cond_109

    const/16 v1, 0x9

    if-gt p2, v1, :cond_109

    .line 329
    const/16 v8, 0x12

    goto/16 :goto_12

    .line 330
    :cond_109
    const/16 v1, 0x17

    if-lt p2, v1, :cond_12

    const/16 v1, 0x18

    if-gt p2, v1, :cond_12

    .line 331
    const/16 v8, 0x13

    goto/16 :goto_12

    .line 333
    :cond_115
    const/16 v1, 0xb

    if-ne p1, v1, :cond_12b

    .line 334
    if-lt p2, v2, :cond_121

    if-gt p2, v6, :cond_121

    .line 335
    const/16 v8, 0x14

    goto/16 :goto_12

    .line 336
    :cond_121
    if-lt p2, v4, :cond_12

    const/16 v1, 0x17

    if-gt p2, v1, :cond_12

    .line 337
    const/16 v8, 0x15

    goto/16 :goto_12

    .line 339
    :cond_12b
    const/16 v1, 0xc

    if-ne p1, v1, :cond_12

    .line 340
    if-lt p2, v3, :cond_137

    if-gt p2, v6, :cond_137

    .line 341
    const/16 v8, 0x16

    goto/16 :goto_12

    .line 342
    :cond_137
    const/16 v1, 0x15

    if-lt p2, v1, :cond_12

    const/16 v1, 0x17

    if-gt p2, v1, :cond_12

    .line 343
    const/16 v8, 0x17

    goto/16 :goto_12
.end method

.method private static Lunar1(Ljava/util/Date;III)V
    .registers 15
    .parameter "objDate"
    .parameter "syear"
    .parameter "smonth"
    .parameter "sday"

    .prologue
    const/4 v10, 0x1

    const/4 v9, 0x0

    .line 191
    const/4 v2, 0x0

    .local v2, leap:I
    const/4 v4, 0x0

    .line 192
    .local v4, temp:I
    new-instance v0, Ljava/util/Date;

    const/16 v5, 0x1f

    invoke-direct {v0, v9, v9, v5}, Ljava/util/Date;-><init>(III)V

    .line 193
    .local v0, baseDate:Ljava/util/Date;
    invoke-virtual {p0}, Ljava/util/Date;->getTime()J

    move-result-wide v5

    invoke-virtual {v0}, Ljava/util/Date;->getTime()J

    move-result-wide v7

    sub-long/2addr v5, v7

    const-wide/32 v7, 0x5265c00

    div-long/2addr v5, v7

    long-to-int v3, v5

    .line 194
    .local v3, offset:I
    const/16 v1, 0x76c

    .local v1, i:I
    :goto_1b
    const/16 v5, 0x802

    if-ge v1, v5, :cond_29

    if-lez v3, :cond_29

    .line 196
    invoke-static {v1}, Landroid/util/Lunar;->lYearDays(I)I

    move-result v4

    .line 197
    sub-int/2addr v3, v4

    .line 194
    add-int/lit8 v1, v1, 0x1

    goto :goto_1b

    .line 200
    :cond_29
    if-gez v3, :cond_2e

    .line 202
    add-int/2addr v3, v4

    .line 203
    add-int/lit8 v1, v1, -0x1

    .line 205
    :cond_2e
    sput v1, Landroid/util/Lunar;->year:I

    .line 206
    invoke-static {v1}, Landroid/util/Lunar;->leapMonth(I)I

    move-result v2

    .line 207
    sput-boolean v9, Landroid/util/Lunar;->isLeap:Z

    .line 208
    const/4 v1, 0x1

    :goto_37
    const/16 v5, 0xd

    if-ge v1, v5, :cond_6a

    if-lez v3, :cond_6a

    .line 210
    if-lez v2, :cond_63

    add-int/lit8 v5, v2, 0x1

    if-ne v1, v5, :cond_63

    sget-boolean v5, Landroid/util/Lunar;->isLeap:Z

    if-nez v5, :cond_63

    .line 212
    add-int/lit8 v1, v1, -0x1

    .line 213
    sput-boolean v10, Landroid/util/Lunar;->isLeap:Z

    .line 214
    sget v5, Landroid/util/Lunar;->year:I

    invoke-static {v5}, Landroid/util/Lunar;->leapDays(I)I

    move-result v4

    .line 221
    :goto_51
    sget-boolean v5, Landroid/util/Lunar;->isLeap:Z

    if-eqz v5, :cond_5b

    add-int/lit8 v5, v2, 0x1

    if-ne v1, v5, :cond_5b

    .line 223
    sput-boolean v9, Landroid/util/Lunar;->isLeap:Z

    .line 225
    :cond_5b
    sub-int/2addr v3, v4

    .line 226
    sget-boolean v5, Landroid/util/Lunar;->isLeap:Z

    if-eqz v5, :cond_60

    .line 208
    :cond_60
    add-int/lit8 v1, v1, 0x1

    goto :goto_37

    .line 218
    :cond_63
    sget v5, Landroid/util/Lunar;->year:I

    invoke-static {v5, v1}, Landroid/util/Lunar;->monthDays(II)I

    move-result v4

    goto :goto_51

    .line 230
    :cond_6a
    if-nez v3, :cond_78

    if-lez v2, :cond_78

    add-int/lit8 v5, v2, 0x1

    if-ne v1, v5, :cond_78

    .line 232
    sget-boolean v5, Landroid/util/Lunar;->isLeap:Z

    if-eqz v5, :cond_8a

    .line 234
    sput-boolean v9, Landroid/util/Lunar;->isLeap:Z

    .line 243
    :cond_78
    :goto_78
    if-gez v3, :cond_7d

    .line 245
    add-int/2addr v3, v4

    .line 246
    add-int/lit8 v1, v1, -0x1

    .line 248
    :cond_7d
    sput v1, Landroid/util/Lunar;->month:I

    .line 249
    add-int/lit8 v5, v3, 0x1

    sput v5, Landroid/util/Lunar;->day:I

    .line 250
    invoke-static {p1, p2, p3}, Landroid/util/Lunar;->ChineseTwentyFourDay(III)Ljava/lang/String;

    move-result-object v5

    sput-object v5, Landroid/util/Lunar;->solarTerm:Ljava/lang/String;

    .line 251
    return-void

    .line 238
    :cond_8a
    sput-boolean v10, Landroid/util/Lunar;->isLeap:Z

    .line 239
    add-int/lit8 v1, v1, -0x1

    goto :goto_78
.end method

.method private static cDay(I)Ljava/lang/String;
    .registers 5
    .parameter "d"

    .prologue
    .line 61
    sparse-switch p0, :sswitch_data_2e

    .line 76
    sget-object v1, Landroid/util/Lunar;->nStr2:[Ljava/lang/String;

    div-int/lit8 v2, p0, 0xa

    aget-object v0, v1, v2

    .line 78
    .local v0, s:Ljava/lang/String;
    new-instance v1, Ljava/lang/StringBuilder;

    invoke-direct {v1}, Ljava/lang/StringBuilder;-><init>()V

    invoke-virtual {v1, v0}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v1

    sget-object v2, Landroid/util/Lunar;->nStr1:[Ljava/lang/String;

    rem-int/lit8 v3, p0, 0xa

    aget-object v2, v2, v3

    invoke-virtual {v1, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v1

    invoke-virtual {v1}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v0

    .line 81
    :goto_20
    return-object v0

    .line 64
    .end local v0       #s:Ljava/lang/String;,
    :sswitch_21
    const-string/jumbo v0, "\u521d\u5341"

    .line 66
    .restart local v0       #s:Ljava/lang/String;,
    goto :goto_20

    .line 68
    .end local v0       #s:Ljava/lang/String;,
    :sswitch_25
    const-string/jumbo v0, "\u4e8c\u5341"

    .line 70
    .restart local v0       #s:Ljava/lang/String;,
    goto :goto_20

    .line 72
    .end local v0       #s:Ljava/lang/String;,
    :sswitch_29
    const-string/jumbo v0, "\u4e09\u5341"

    .line 74
    .restart local v0       #s:Ljava/lang/String;,
    goto :goto_20

    .line 61
    nop

    :sswitch_data_2e
    .sparse-switch
        0xa -> :sswitch_21
        0x14 -> :sswitch_25
        0x1e -> :sswitch_29
    .end sparse-switch
.end method

.method public static getDay()I
    .registers 1

    .prologue
    .line 86
    sget v0, Landroid/util/Lunar;->day:I

    return v0
.end method

.method public static getIsBig()Z
    .registers 2

    .prologue
    .line 92
    invoke-static {}, Landroid/util/Lunar;->getYear()I

    move-result v0

    invoke-static {}, Landroid/util/Lunar;->getMonth()I

    move-result v1

    invoke-static {v0, v1}, Landroid/util/Lunar;->monthDays(II)I

    move-result v0

    const/16 v1, 0x1d

    if-eq v0, v1, :cond_12

    const/4 v0, 0x1

    :goto_11
    return v0

    :cond_12
    const/4 v0, 0x0

    goto :goto_11
.end method

.method public static getIsLeap()Z
    .registers 1

    .prologue
    .line 97
    sget-boolean v0, Landroid/util/Lunar;->isLeap:Z

    return v0
.end method

.method public static getLunar(IZ)Ljava/lang/String;
    .registers 14
    .parameter "t"
    .parameter "dh"

    .prologue
    const/4 v11, 0x5

    const/4 v10, 0x4

    const/4 v9, 0x3

    const/4 v8, 0x2

    const/4 v7, 0x1

    .line 108
    if-eqz p1, :cond_15

    const-string/jumbo v3, "\uff0c"

    .line 109
    .local v3, s:Ljava/lang/String;
    :goto_a
    if-ne p0, v7, :cond_18

    .line 110
    invoke-static {}, Landroid/util/Lunar;->getDay()I

    move-result v5

    invoke-static {v5}, Landroid/util/Lunar;->cDay(I)Ljava/lang/String;

    move-result-object v5

    .line 139
    :goto_14
    return-object v5

    .line 108
    .end local v3       #s:Ljava/lang/String;,
    :cond_15
    const-string v3, ""

    goto :goto_a

    .line 111
    .restart local v3       #s:Ljava/lang/String;,
    :cond_18
    if-ne p0, v8, :cond_2e

    .line 112
    new-instance v5, Ljava/lang/StringBuilder;

    invoke-direct {v5}, Ljava/lang/StringBuilder;-><init>()V

    invoke-virtual {v5, v3}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v5

    sget-object v6, Landroid/util/Lunar;->solarTerm:Ljava/lang/String;

    invoke-virtual {v5, v6}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v5

    invoke-virtual {v5}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v5

    goto :goto_14

    .line 113
    :cond_2e
    if-ne p0, v9, :cond_46

    .line 114
    new-instance v5, Ljava/lang/StringBuilder;

    invoke-direct {v5}, Ljava/lang/StringBuilder;-><init>()V

    invoke-virtual {v5, v3}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v5

    invoke-static {}, Landroid/util/Lunar;->getMonthViewDay()Ljava/lang/String;

    move-result-object v6

    invoke-virtual {v5, v6}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v5

    invoke-virtual {v5}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v5

    goto :goto_14

    .line 115
    :cond_46
    if-ne p0, v10, :cond_77

    .line 116
    new-instance v5, Ljava/lang/StringBuilder;

    invoke-direct {v5}, Ljava/lang/StringBuilder;-><init>()V

    invoke-virtual {v5, v3}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v6

    sget-boolean v5, Landroid/util/Lunar;->isLeap:Z

    if-eqz v5, :cond_74

    const-string/jumbo v5, "\u95f0"

    :goto_58
    invoke-virtual {v6, v5}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v5

    sget-object v6, Landroid/util/Lunar;->monthNong:[Ljava/lang/String;

    invoke-static {}, Landroid/util/Lunar;->getMonth()I

    move-result v7

    aget-object v6, v6, v7

    invoke-virtual {v5, v6}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v5

    const-string/jumbo v6, "\u6708"

    invoke-virtual {v5, v6}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v5

    invoke-virtual {v5}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v5

    goto :goto_14

    :cond_74
    const-string v5, ""

    goto :goto_58

    .line 117
    :cond_77
    if-ne p0, v11, :cond_b5

    .line 118
    new-instance v5, Ljava/lang/StringBuilder;

    invoke-direct {v5}, Ljava/lang/StringBuilder;-><init>()V

    invoke-virtual {v5, v3}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v6

    sget-boolean v5, Landroid/util/Lunar;->isLeap:Z

    if-eqz v5, :cond_b2

    const-string/jumbo v5, "\u95f0"

    :goto_89
    invoke-virtual {v6, v5}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v5

    sget-object v6, Landroid/util/Lunar;->monthNong:[Ljava/lang/String;

    invoke-static {}, Landroid/util/Lunar;->getMonth()I

    move-result v7

    aget-object v6, v6, v7

    invoke-virtual {v5, v6}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v5

    const-string/jumbo v6, "\u6708"

    invoke-virtual {v5, v6}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v5

    invoke-static {}, Landroid/util/Lunar;->getDay()I

    move-result v6

    invoke-static {v6}, Landroid/util/Lunar;->cDay(I)Ljava/lang/String;

    move-result-object v6

    invoke-virtual {v5, v6}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v5

    invoke-virtual {v5}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v5

    goto/16 :goto_14

    :cond_b2
    const-string v5, ""

    goto :goto_89

    .line 119
    :cond_b5
    const/4 v5, 0x6

    if-ne p0, v5, :cond_ee

    .line 120
    new-instance v5, Ljava/lang/StringBuilder;

    invoke-direct {v5}, Ljava/lang/StringBuilder;-><init>()V

    invoke-virtual {v5, v3}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v6

    sget-boolean v5, Landroid/util/Lunar;->isLeap:Z

    if-eqz v5, :cond_eb

    const-string/jumbo v5, "\u95f0"

    :goto_c8
    invoke-virtual {v6, v5}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v5

    sget-object v6, Landroid/util/Lunar;->monthNong:[Ljava/lang/String;

    invoke-static {}, Landroid/util/Lunar;->getMonth()I

    move-result v7

    aget-object v6, v6, v7

    invoke-virtual {v5, v6}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v5

    const-string/jumbo v6, "\u6708"

    invoke-virtual {v5, v6}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v5

    sget-object v6, Landroid/util/Lunar;->solarTerm:Ljava/lang/String;

    invoke-virtual {v5, v6}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v5

    invoke-virtual {v5}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v5

    goto/16 :goto_14

    :cond_eb
    const-string v5, ""

    goto :goto_c8

    .line 121
    :cond_ee
    const/4 v5, 0x7

    if-ne p0, v5, :cond_129

    .line 122
    new-instance v5, Ljava/lang/StringBuilder;

    invoke-direct {v5}, Ljava/lang/StringBuilder;-><init>()V

    invoke-virtual {v5, v3}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v6

    sget-boolean v5, Landroid/util/Lunar;->isLeap:Z

    if-eqz v5, :cond_126

    const-string/jumbo v5, "\u95f0"

    :goto_101
    invoke-virtual {v6, v5}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v5

    sget-object v6, Landroid/util/Lunar;->monthNong:[Ljava/lang/String;

    invoke-static {}, Landroid/util/Lunar;->getMonth()I

    move-result v7

    aget-object v6, v6, v7

    invoke-virtual {v5, v6}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v5

    const-string/jumbo v6, "\u6708"

    invoke-virtual {v5, v6}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v5

    invoke-static {}, Landroid/util/Lunar;->getMonthViewDay()Ljava/lang/String;

    move-result-object v6

    invoke-virtual {v5, v6}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v5

    invoke-virtual {v5}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v5

    goto/16 :goto_14

    :cond_126
    const-string v5, ""

    goto :goto_101

    .line 123
    :cond_129
    const/16 v5, 0x8

    if-ne p0, v5, :cond_265

    .line 125
    const/16 v5, 0xa

    new-array v1, v5, [Ljava/lang/String;

    const/4 v5, 0x0

    const-string/jumbo v6, "\u7532"

    aput-object v6, v1, v5

    const-string/jumbo v5, "\u4e59"

    aput-object v5, v1, v7

    const-string/jumbo v5, "\u4e19"

    aput-object v5, v1, v8

    const-string/jumbo v5, "\u4e01"

    aput-object v5, v1, v9

    const-string/jumbo v5, "\u620a"

    aput-object v5, v1, v10

    const-string/jumbo v5, "\u5df1"

    aput-object v5, v1, v11

    const/4 v5, 0x6

    const-string/jumbo v6, "\u5e9a"

    aput-object v6, v1, v5

    const/4 v5, 0x7

    const-string/jumbo v6, "\u8f9b"

    aput-object v6, v1, v5

    const/16 v5, 0x8

    const-string/jumbo v6, "\u58ec"

    aput-object v6, v1, v5

    const/16 v5, 0x9

    const-string/jumbo v6, "\u7678"

    aput-object v6, v1, v5

    .line 126
    .local v1, gan:[Ljava/lang/String;
    const/16 v5, 0xc

    new-array v4, v5, [Ljava/lang/String;

    const/4 v5, 0x0

    const-string/jumbo v6, "\u5b50"

    aput-object v6, v4, v5

    const-string/jumbo v5, "\u4e11"

    aput-object v5, v4, v7

    const-string/jumbo v5, "\u5bc5"

    aput-object v5, v4, v8

    const-string/jumbo v5, "\u536f"

    aput-object v5, v4, v9

    const-string/jumbo v5, "\u8fb0"

    aput-object v5, v4, v10

    const-string/jumbo v5, "\u5df3"

    aput-object v5, v4, v11

    const/4 v5, 0x6

    const-string/jumbo v6, "\u5348"

    aput-object v6, v4, v5

    const/4 v5, 0x7

    const-string/jumbo v6, "\u672a"

    aput-object v6, v4, v5

    const/16 v5, 0x8

    const-string/jumbo v6, "\u7533"

    aput-object v6, v4, v5

    const/16 v5, 0x9

    const-string/jumbo v6, "\u9149"

    aput-object v6, v4, v5

    const/16 v5, 0xa

    const-string/jumbo v6, "\u620c"

    aput-object v6, v4, v5

    const/16 v5, 0xb

    const-string/jumbo v6, "\u4ea5"

    aput-object v6, v4, v5

    .line 127
    .local v4, zhi:[Ljava/lang/String;
    const/16 v5, 0xc

    new-array v0, v5, [Ljava/lang/String;

    const/4 v5, 0x0

    const-string/jumbo v6, "\u9f20"

    aput-object v6, v0, v5

    const-string/jumbo v5, "\u725b"

    aput-object v5, v0, v7

    const-string/jumbo v5, "\u864e"

    aput-object v5, v0, v8

    const-string/jumbo v5, "\u5154"

    aput-object v5, v0, v9

    const-string/jumbo v5, "\u9f99"

    aput-object v5, v0, v10

    const-string/jumbo v5, "\u86c7"

    aput-object v5, v0, v11

    const/4 v5, 0x6

    const-string/jumbo v6, "\u9a6c"

    aput-object v6, v0, v5

    const/4 v5, 0x7

    const-string/jumbo v6, "\u7f8a"

    aput-object v6, v0, v5

    const/16 v5, 0x8

    const-string/jumbo v6, "\u7334"

    aput-object v6, v0, v5

    const/16 v5, 0x9

    const-string/jumbo v6, "\u9e21"

    aput-object v6, v0, v5

    const/16 v5, 0xa

    const-string/jumbo v6, "\u72d7"

    aput-object v6, v0, v5

    const/16 v5, 0xb

    const-string/jumbo v6, "\u732a"

    aput-object v6, v0, v5

    .line 128
    .local v0, animals:[Ljava/lang/String;
    sget v5, Landroid/util/Lunar;->year:I

    add-int/lit16 v5, v5, -0x76c

    add-int/lit8 v2, v5, 0x24

    .line 129
    .local v2, num:I
    new-instance v5, Ljava/lang/StringBuilder;

    invoke-direct {v5}, Ljava/lang/StringBuilder;-><init>()V

    invoke-virtual {v5, v3}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v5

    rem-int/lit8 v6, v2, 0xa

    aget-object v6, v1, v6

    invoke-virtual {v5, v6}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v5

    rem-int/lit8 v6, v2, 0xc

    aget-object v6, v4, v6

    invoke-virtual {v5, v6}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v5

    sget v6, Landroid/util/Lunar;->year:I

    add-int/lit8 v6, v6, -0x4

    rem-int/lit8 v6, v6, 0xc

    aget-object v6, v0, v6

    invoke-virtual {v5, v6}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v5

    const-string/jumbo v6, "\u5e74"

    invoke-virtual {v5, v6}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v6

    sget-boolean v5, Landroid/util/Lunar;->isLeap:Z

    if-eqz v5, :cond_262

    const-string/jumbo v5, "\u95f0"

    :goto_239
    invoke-virtual {v6, v5}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v5

    sget-object v6, Landroid/util/Lunar;->monthNong:[Ljava/lang/String;

    invoke-static {}, Landroid/util/Lunar;->getMonth()I

    move-result v7

    aget-object v6, v6, v7

    invoke-virtual {v5, v6}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v5

    const-string/jumbo v6, "\u6708"

    invoke-virtual {v5, v6}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v5

    invoke-static {}, Landroid/util/Lunar;->getDay()I

    move-result v6

    invoke-static {v6}, Landroid/util/Lunar;->cDay(I)Ljava/lang/String;

    move-result-object v6

    invoke-virtual {v5, v6}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v5

    invoke-virtual {v5}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v5

    goto/16 :goto_14

    :cond_262
    const-string v5, ""

    goto :goto_239

    .line 131
    .end local v0       #animals:[Ljava/lang/String;,
    .end local v1       #gan:[Ljava/lang/String;,
    .end local v2       #num:I,
    .end local v4       #zhi:[Ljava/lang/String;,
    :cond_265
    const/16 v5, 0x9

    if-ne p0, v5, :cond_395

    .line 132
    const/16 v5, 0xa

    new-array v1, v5, [Ljava/lang/String;

    const/4 v5, 0x0

    const-string/jumbo v6, "\u7532"

    aput-object v6, v1, v5

    const-string/jumbo v5, "\u4e59"

    aput-object v5, v1, v7

    const-string/jumbo v5, "\u4e19"

    aput-object v5, v1, v8

    const-string/jumbo v5, "\u4e01"

    aput-object v5, v1, v9

    const-string/jumbo v5, "\u620a"

    aput-object v5, v1, v10

    const-string/jumbo v5, "\u5df1"

    aput-object v5, v1, v11

    const/4 v5, 0x6

    const-string/jumbo v6, "\u5e9a"

    aput-object v6, v1, v5

    const/4 v5, 0x7

    const-string/jumbo v6, "\u8f9b"

    aput-object v6, v1, v5

    const/16 v5, 0x8

    const-string/jumbo v6, "\u58ec"

    aput-object v6, v1, v5

    const/16 v5, 0x9

    const-string/jumbo v6, "\u7678"

    aput-object v6, v1, v5

    .line 133
    .restart local v1       #gan:[Ljava/lang/String;,
    const/16 v5, 0xc

    new-array v4, v5, [Ljava/lang/String;

    const/4 v5, 0x0

    const-string/jumbo v6, "\u5b50"

    aput-object v6, v4, v5

    const-string/jumbo v5, "\u4e11"

    aput-object v5, v4, v7

    const-string/jumbo v5, "\u5bc5"

    aput-object v5, v4, v8

    const-string/jumbo v5, "\u536f"

    aput-object v5, v4, v9

    const-string/jumbo v5, "\u8fb0"

    aput-object v5, v4, v10

    const-string/jumbo v5, "\u5df3"

    aput-object v5, v4, v11

    const/4 v5, 0x6

    const-string/jumbo v6, "\u5348"

    aput-object v6, v4, v5

    const/4 v5, 0x7

    const-string/jumbo v6, "\u672a"

    aput-object v6, v4, v5

    const/16 v5, 0x8

    const-string/jumbo v6, "\u7533"

    aput-object v6, v4, v5

    const/16 v5, 0x9

    const-string/jumbo v6, "\u9149"

    aput-object v6, v4, v5

    const/16 v5, 0xa

    const-string/jumbo v6, "\u620c"

    aput-object v6, v4, v5

    const/16 v5, 0xb

    const-string/jumbo v6, "\u4ea5"

    aput-object v6, v4, v5

    .line 134
    .restart local v4       #zhi:[Ljava/lang/String;,
    const/16 v5, 0xc

    new-array v0, v5, [Ljava/lang/String;

    const/4 v5, 0x0

    const-string/jumbo v6, "\u9f20"

    aput-object v6, v0, v5

    const-string/jumbo v5, "\u725b"

    aput-object v5, v0, v7

    const-string/jumbo v5, "\u864e"

    aput-object v5, v0, v8

    const-string/jumbo v5, "\u5154"

    aput-object v5, v0, v9

    const-string/jumbo v5, "\u9f99"

    aput-object v5, v0, v10

    const-string/jumbo v5, "\u86c7"

    aput-object v5, v0, v11

    const/4 v5, 0x6

    const-string/jumbo v6, "\u9a6c"

    aput-object v6, v0, v5

    const/4 v5, 0x7

    const-string/jumbo v6, "\u7f8a"

    aput-object v6, v0, v5

    const/16 v5, 0x8

    const-string/jumbo v6, "\u7334"

    aput-object v6, v0, v5

    const/16 v5, 0x9

    const-string/jumbo v6, "\u9e21"

    aput-object v6, v0, v5

    const/16 v5, 0xa

    const-string/jumbo v6, "\u72d7"

    aput-object v6, v0, v5

    const/16 v5, 0xb

    const-string/jumbo v6, "\u732a"

    aput-object v6, v0, v5

    .line 135
    .restart local v0       #animals:[Ljava/lang/String;,
    sget v5, Landroid/util/Lunar;->year:I

    add-int/lit16 v5, v5, -0x76c

    add-int/lit8 v2, v5, 0x24

    .line 136
    .restart local v2       #num:I,
    new-instance v5, Ljava/lang/StringBuilder;

    invoke-direct {v5}, Ljava/lang/StringBuilder;-><init>()V

    invoke-virtual {v5, v3}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v5

    rem-int/lit8 v6, v2, 0xa

    aget-object v6, v1, v6

    invoke-virtual {v5, v6}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v5

    rem-int/lit8 v6, v2, 0xc

    aget-object v6, v4, v6

    invoke-virtual {v5, v6}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v5

    sget v6, Landroid/util/Lunar;->year:I

    add-int/lit8 v6, v6, -0x4

    rem-int/lit8 v6, v6, 0xc

    aget-object v6, v0, v6

    invoke-virtual {v5, v6}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v5

    const-string/jumbo v6, "\u5e74"

    invoke-virtual {v5, v6}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v6

    sget-boolean v5, Landroid/util/Lunar;->isLeap:Z

    if-eqz v5, :cond_392

    const-string/jumbo v5, "\u95f0"

    :goto_375
    invoke-virtual {v6, v5}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v5

    sget-object v6, Landroid/util/Lunar;->monthNong:[Ljava/lang/String;

    invoke-static {}, Landroid/util/Lunar;->getMonth()I

    move-result v7

    aget-object v6, v6, v7

    invoke-virtual {v5, v6}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v5

    const-string/jumbo v6, "\u6708"

    invoke-virtual {v5, v6}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v5

    invoke-virtual {v5}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v5

    goto/16 :goto_14

    :cond_392
    const-string v5, ""

    goto :goto_375

    .line 139
    .end local v0       #animals:[Ljava/lang/String;,
    .end local v1       #gan:[Ljava/lang/String;,
    .end local v2       #num:I,
    .end local v4       #zhi:[Ljava/lang/String;,
    :cond_395
    const-string v5, ""

    goto/16 :goto_14
.end method

.method public static getLunarDay()Ljava/lang/String;
    .registers 1

    .prologue
    .line 149
    invoke-static {}, Landroid/util/Lunar;->getDay()I

    move-result v0

    invoke-static {v0}, Landroid/util/Lunar;->cDay(I)Ljava/lang/String;

    move-result-object v0

    return-object v0
.end method

.method public static getLunarMonth()Ljava/lang/String;
    .registers 3

    .prologue
    .line 153
    new-instance v0, Ljava/lang/StringBuilder;

    invoke-direct {v0}, Ljava/lang/StringBuilder;-><init>()V

    sget-object v1, Landroid/util/Lunar;->monthNong:[Ljava/lang/String;

    invoke-static {}, Landroid/util/Lunar;->getMonth()I

    move-result v2

    aget-object v1, v1, v2

    invoke-virtual {v0, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v0

    const-string/jumbo v1, "\u6708"

    invoke-virtual {v0, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v0

    invoke-virtual {v0}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v0

    return-object v0
.end method

.method public static getMonth()I
    .registers 1

    .prologue
    .line 144
    sget v0, Landroid/util/Lunar;->month:I

    return v0
.end method

.method private static getMonthViewDay()Ljava/lang/String;
    .registers 3

    .prologue
    .line 158
    sget-object v1, Landroid/util/Lunar;->solarTerm:Ljava/lang/String;

    const-string v2, ""

    if-eq v1, v2, :cond_9

    .line 159
    sget-object v0, Landroid/util/Lunar;->solarTerm:Ljava/lang/String;

    .line 164
    .local v0, tmp:Ljava/lang/String;
    :goto_8
    return-object v0

    .line 160
    .end local v0       #tmp:Ljava/lang/String;,
    :cond_9
    sget v1, Landroid/util/Lunar;->day:I

    const/4 v2, 0x1

    if-ne v1, v2, :cond_13

    .line 161
    invoke-static {}, Landroid/util/Lunar;->getLunarMonth()Ljava/lang/String;

    move-result-object v0

    .restart local v0       #tmp:Ljava/lang/String;,
    goto :goto_8

    .line 163
    .end local v0       #tmp:Ljava/lang/String;,
    :cond_13
    invoke-static {}, Landroid/util/Lunar;->getDay()I

    move-result v1

    invoke-static {v1}, Landroid/util/Lunar;->cDay(I)Ljava/lang/String;

    move-result-object v0

    .restart local v0       #tmp:Ljava/lang/String;,
    goto :goto_8
.end method

.method public static getYear()I
    .registers 1

    .prologue
    .line 169
    sget v0, Landroid/util/Lunar;->year:I

    return v0
.end method

.method private static lYearDays(I)I
    .registers 5
    .parameter "y"

    .prologue
    .line 255
    const/16 v1, 0x15c

    .line 257
    .local v1, sum:I
    const v0, 0x8000

    .local v0, i:I
    :goto_5
    const/16 v2, 0x8

    if-le v0, v2, :cond_19

    .line 259
    sget-object v2, Landroid/util/Lunar;->lunarInfo:[I

    add-int/lit16 v3, p0, -0x76c

    aget v2, v2, v3

    and-int/2addr v2, v0

    if-nez v2, :cond_17

    const/4 v2, 0x0

    :goto_13
    add-int/2addr v1, v2

    .line 257
    shr-int/lit8 v0, v0, 0x1

    goto :goto_5

    .line 259
    :cond_17
    const/4 v2, 0x1

    goto :goto_13

    .line 262
    :cond_19
    invoke-static {p0}, Landroid/util/Lunar;->leapDays(I)I

    move-result v2

    add-int/2addr v2, v1

    return v2
.end method

.method private static leapDays(I)I
    .registers 3
    .parameter "y"

    .prologue
    .line 175
    invoke-static {p0}, Landroid/util/Lunar;->leapMonth(I)I

    move-result v0

    if-eqz v0, :cond_17

    .line 177
    sget-object v0, Landroid/util/Lunar;->lunarInfo:[I

    add-int/lit16 v1, p0, -0x76c

    aget v0, v0, v1

    const/high16 v1, 0x1

    and-int/2addr v0, v1

    if-nez v0, :cond_14

    const/16 v0, 0x1d

    .line 180
    :goto_13
    return v0

    .line 177
    :cond_14
    const/16 v0, 0x1e

    goto :goto_13

    .line 180
    :cond_17
    const/4 v0, 0x0

    goto :goto_13
.end method

.method private static leapMonth(I)I
    .registers 3
    .parameter "y"

    .prologue
    .line 185
    sget-object v0, Landroid/util/Lunar;->lunarInfo:[I

    add-int/lit16 v1, p0, -0x76c

    aget v0, v0, v1

    and-int/lit8 v0, v0, 0xf

    return v0
.end method

.method private static monthDays(II)I
    .registers 4
    .parameter "y"
    .parameter "m"

    .prologue
    .line 267
    sget-object v0, Landroid/util/Lunar;->lunarInfo:[I

    add-int/lit16 v1, p0, -0x76c

    aget v0, v0, v1

    const/high16 v1, 0x1

    shr-int/2addr v1, p1

    and-int/2addr v0, v1

    if-nez v0, :cond_f

    const/16 v0, 0x1d

    :goto_e
    return v0

    :cond_f
    const/16 v0, 0x1e

    goto :goto_e
.end method

.method public static setLunar(III)V
    .registers 5
    .parameter "year"
    .parameter "month"
    .parameter "day"

    .prologue
    .line 102
    sget-boolean v1, Landroid/util/Lunar;->isSetShowLunch:Z

    if-eqz v1, :cond_8

    sget-boolean v1, Landroid/util/Lunar;->isShowLunch:Z

    if-eqz v1, :cond_12

    .line 103
    :cond_8
    new-instance v0, Ljava/util/Date;

    add-int/lit16 v1, p0, -0x76c

    invoke-direct {v0, v1, p1, p2}, Ljava/util/Date;-><init>(III)V

    .line 104
    .local v0, sDObj:Ljava/util/Date;
    invoke-static {v0, p0, p1, p2}, Landroid/util/Lunar;->Lunar1(Ljava/util/Date;III)V

    .line 106
    .end local v0       #sDObj:Ljava/util/Date;,
    :cond_12
    return-void
.end method
EOF

# get the start & end lines what will be modifed in policy 
start=$(sed -n '/.method\ refreshDate/=' $c_p_dir/com/android/internal/policy/impl/KeyguardStatusViewManager.smali)
end=$(sed -n "$start,/.end\ method/=" $c_p_dir/com/android/internal/policy/impl/KeyguardStatusViewManager.smali | sed -n '$ p')
sed "$start,$end d" $c_p_dir/com/android/internal/policy/impl/KeyguardStatusViewManager.smali > $tdir/tmp_ksvm.smali
sed -i "$[$start-1] r $code" $tdir/tmp_ksvm.smali 
cp -f $tdir/tmp_ksvm.smali $c_p_dir/com/android/internal/policy/impl/KeyguardStatusViewManager.smali 

if [[ $? != 0 ]]; then
    echo "cp the new file failure!"
    exit 1
fi

# output directory
jar_new=jar_new
if [[ ! -d $jar_new ]]; then
    mkdir $jar_new
fi

# jar2dex
smali $c_p_dir -o $tdir/classes.dex
cp $tdir/classes.dex $tdir/classes_policy_new.dex
cp android.policy.jar $tdir/android.policy.jar 
cd $tdir
zip -u android.policy.jar classes.dex 
cd ../
mv $tdir/android.policy.jar $jar_new/android.policy.jar
smali $c_f_dir -o $tdir/classes.dex
cp $tdir/classes.dex $tdir/classes_framework_new.dex
cp framework.jar $tdir/framework.jar 
cd $tdir
zip -u framework.jar classes.dex 
cd ../
mv $tdir/framework.jar $jar_new/framework.jar
rm -rf $tdir
rm -rf *.jar

echo "I: All done, output directory is $jar_new, enjoy!"
