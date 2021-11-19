from launch import LaunchDescription
from launch.actions import DeclareLaunchArgument
from launch.substitutions import Command, FindExecutable, LaunchConfiguration, PathJoinSubstitution

from launch_ros.actions import Node
from launch_ros.substitutions import FindPackageShare


def generate_launch_description():
    model = DeclareLaunchArgument(
        "model", description="URDF/XACRO description file with the robot.", default_value="iiwa"
    )
    robot = DeclareLaunchArgument(
        "robot", description="Choose between iiwa7 and iiwa14.", default_value="iiwa7"
    )

    robot_description_content = Command(
        [
            PathJoinSubstitution([FindExecutable(name="xacro")]),
            " ",
            PathJoinSubstitution(
                [FindPackageShare("kuka_iiwa_description"), "robots/", LaunchConfiguration("model")]),
            ".urdf.xacro"
            " ",
            "robot:=",
            LaunchConfiguration("robot")
        ]
    )

    robot_state_pub_node = Node(
        package="robot_state_publisher",
        executable="robot_state_publisher",
        output="both",
        parameters=[{"robot_description": robot_description_content}],
    )

    joint_state_pub_node = Node(
        package="joint_state_publisher_gui",
        executable="joint_state_publisher_gui",
        output="both",
    )

    rviz_node = Node(
        package="rviz2",
        executable="rviz2",
        name="rviz2",
        arguments=["-d", PathJoinSubstitution([FindPackageShare("kuka_iiwa_description"), "config/iiwa.rviz"])],
        output="log",
    )

    nodes = [
        robot_state_pub_node,
        joint_state_pub_node,
        rviz_node,
    ]

    return LaunchDescription([model, robot] + nodes)
