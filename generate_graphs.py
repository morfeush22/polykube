import os
from pathlib import Path

from matplotlib import pyplot as plt


def generate_graph_metadata(x, poly_s, mono_s):
    polyrepo_metadata = {
        "data": [x, poly_s],
        "style": {
            "linestyle": "dashed",
            "marker": "o",
            "fillstyle": "none",
            "color": "blue",
        },
        "label": f"Polyrepo",
    }

    monorepo_metadata = {
        "data": [x, mono_s],
        "style": {
            "linestyle": "dashdot",
            "marker": "s",
            "fillstyle": "none",
            "color": "green",
        },
        "label": f"Monorepo",
    }

    return polyrepo_metadata, monorepo_metadata


def generate_graph(polyrepo_metadata, monorepo_metadata, title, x_axis_label, y_axis_label):
    fig, ax1 = plt.subplots()

    polyrepo_color = polyrepo_metadata["style"]["color"]

    ax1.set_title(title, pad=20)
    ax1.set_xlabel(f"{x_axis_label}")
    ax1.set_ylabel(f"{y_axis_label}", color=polyrepo_color)
    ax1.tick_params(axis='y', labelcolor=polyrepo_color)
    ax1.ticklabel_format(style='plain')

    x = polyrepo_metadata["data"][0]
    y = polyrepo_metadata["data"][1]

    polyrepo_style = polyrepo_metadata["style"]
    polyrepo_label = polyrepo_metadata["label"]

    ax1.xaxis.set_ticks(x)

    lns1 = ax1.plot(x, y, **polyrepo_style, label=polyrepo_label)

    ax1.grid(linestyle='dashed')
    ax1.margins(0.125, 0.2)

    plt.setp(ax1.get_xticklabels(), rotation=0, horizontalalignment="right")

    ax2 = ax1.twinx()

    monorepo_color = monorepo_metadata["style"]["color"]

    ax2.set_title(title, pad=20)
    ax2.set_ylabel(f"{y_axis_label}", color=monorepo_color)
    ax2.tick_params(axis='y', labelcolor=monorepo_color)
    ax2.ticklabel_format(style='plain')

    y = monorepo_metadata["data"][1]

    monorepo_style = monorepo_metadata["style"]
    monorepo_label = monorepo_metadata["label"]

    lns2 = ax2.plot(x, y, **monorepo_style, label=monorepo_label)

    ax2.margins(0.125, 0.2)

    lns = lns1 + lns2
    labs = [l.get_label() for l in lns]
    lgd = ax1.legend(lns, labs, loc="upper center", bbox_to_anchor=(0.5, -0.25), ncol=2)

    return fig, lgd


def create_destination_path(basedir, path):
    final_path = os.path.join(basedir, path)
    Path(os.path.dirname(final_path)).mkdir(parents=True, exist_ok=True)

    return final_path


def save_graph_to_file(fig, lgd, path, basedir="data"):
    final_path = create_destination_path(basedir, path)

    if lgd is not None:
        fig.savefig(final_path, bbox_extra_artists=(lgd,), bbox_inches="tight")
    else:
        fig.savefig(final_path)

    plt.close(fig)


def generate_graphs():
    for test_result in test_results:
        commit = test_result["commit"]

        # max number of common nodes = possible configurations
        n = 5

        x = [i for i in range(1, n + 1)]

        wait_poly_s = [result["times"][0] for result in test_result["results"]][:n]
        build_poly_s = [result["times"][1] for result in test_result["results"]][:n]
        total_poly_s = [result["times"][2] // 1000 for result in test_result["results"]][:n]  # total in ms

        wait_mono_s = [test_result["results"][n]["times"][0] for i in range(1, n + 1)]
        build_mono_s = [test_result["results"][n]["times"][1] for i in range(1, n + 1)]
        total_mono_s = [test_result["results"][n]["times"][2] // 1000 for i in range(1, n + 1)]  # total in ms

        x_axis_label = "Liczba węzłów roboczych common [jednostki]"
        y_axis_label = "Czas [s]"

        polyrepo_metadata, monorepo_metadata = generate_graph_metadata(x, wait_poly_s, wait_mono_s)
        title = f"Scenariusz {commit}, czas oczekiwania"
        fig, lgd = generate_graph(polyrepo_metadata, monorepo_metadata, title, x_axis_label, y_axis_label)
        wait_graph_path = f"{commit}/wait.png"
        save_graph_to_file(fig, lgd, wait_graph_path)

        polyrepo_metadata, monorepo_metadata = generate_graph_metadata(x, build_poly_s, build_mono_s)
        title = f"Scenariusz {commit}, czas budowania"
        fig, lgd = generate_graph(polyrepo_metadata, monorepo_metadata, title, x_axis_label, y_axis_label)
        build_graph_path = f"{commit}/build.png"
        save_graph_to_file(fig, lgd, build_graph_path)

        polyrepo_metadata, monorepo_metadata = generate_graph_metadata(x, total_poly_s, total_mono_s)
        title = f"Scenariusz {commit}, czas pełnej pętli zwrotnej"
        fig, lgd = generate_graph(polyrepo_metadata, monorepo_metadata, title, x_axis_label, y_axis_label)
        total_graph_path = f"{commit}/total.png"
        save_graph_to_file(fig, lgd, total_graph_path)


def main():
    generate_graphs()


test_results = [
    {
        "commit": "a1892cea1a7120952d978509f4cb616bbd3837cd",
        "results": [
            {
                "times": [2889180, 97424, 84249667],
                "common_count": 1,
                "e2e_cluster_count": 1,
            },
            {
                "times": [1316700, 96669, 41952001],
                "common_count": 2,
                "e2e_cluster_count": 1,
            },
            {
                "times": [1033140, 108340, 32384674],
                "common_count": 3,
                "e2e_cluster_count": 1,
            },
            {
                "times": [809746, 117155, 26464662],
                "common_count": 4,
                "e2e_cluster_count": 1,
            },
            {
                "times": [829704, 149900, 28081851],
                "common_count": 5,
                "e2e_cluster_count": 1,
            },
            {
                "times": [92, 15689, 9563513],
                "common_count": 1,
                "e2e_cluster_count": 1,
            },
        ],
    },
    {
        "commit": "e09055bf5ce80b600099222539e1496794063908",
        "results": [
            {
                "times": [2728490, 97302, 84520545],
                "common_count": 1,
                "e2e_cluster_count": 1,
            },
            {
                "times": [1325160, 94255, 40991581],
                "common_count": 2,
                "e2e_cluster_count": 1,
            },
            {
                "times": [1090550, 112634, 33533416],
                "common_count": 3,
                "e2e_cluster_count": 1,
            },
            {
                "times": [686942, 102268, 22798305],
                "common_count": 4,
                "e2e_cluster_count": 1,
            },
            {
                "times": [782159, 145441, 26940394],
                "common_count": 5,
                "e2e_cluster_count": 1,
            },
            {
                "times": [95, 16551, 10386992],
                "common_count": 1,
                "e2e_cluster_count": 1,
            },
        ],
    },
    {
        "commit": "a5e231aad7378083645b234bb537cdfb58cfd078",
        "results": [
            {
                "times": [20, 7806, 7829776],
                "common_count": 1,
                "e2e_cluster_count": 1,
            },
            {
                "times": [19, 8272, 8294520],
                "common_count": 2,
                "e2e_cluster_count": 1,
            },
            {
                "times": [20, 8381, 8404290],
                "common_count": 3,
                "e2e_cluster_count": 1,
            },
            {
                "times": [20, 7800, 7822234],
                "common_count": 4,
                "e2e_cluster_count": 1,
            },
            {
                "times": [16, 8387, 8406997],
                "common_count": 5,
                "e2e_cluster_count": 1,
            },
            {
                "times": [94, 15623, 9631367],
                "common_count": 1,
                "e2e_cluster_count": 1,
            },
        ],
    },
    {
        "commit": "2d0456982edc2e1dc415b01a0345206858a55387",
        "results": [
            {
                "times": [446337, 22912, 23958392],
                "common_count": 1,
                "e2e_cluster_count": 1,
            },
            {
                "times": [267838, 29053, 15817749],
                "common_count": 2,
                "e2e_cluster_count": 1,
            },
            {
                "times": [182146, 30628, 10715265],
                "common_count": 3,
                "e2e_cluster_count": 1,
            },
            {
                "times": [153801, 36028, 9696952],
                "common_count": 4,
                "e2e_cluster_count": 1,
            },
            {
                "times": [127467, 38292, 8746765],
                "common_count": 5,
                "e2e_cluster_count": 1,
            },
            {
                "times": [98, 16430, 10392029],
                "common_count": 1,
                "e2e_cluster_count": 1,
            },
        ],
    },
    {
        "commit": "86c8e960eeabd346a92457973d41abd865eccb5f",
        "results": [
            {
                "times": [7597520, 208518, 161002852],
                "common_count": 1,
                "e2e_cluster_count": 1,
            },
            {
                "times": [3403200, 172906, 70399001],
                "common_count": 2,
                "e2e_cluster_count": 1,
            },
            {
                "times": [3278860, 245481, 71179522],
                "common_count": 3,
                "e2e_cluster_count": 1,
            },
            {
                "times": [1832650, 182396, 39756775],
                "common_count": 4,
                "e2e_cluster_count": 1,
            },
            {
                "times": [1503410, 181731, 33422515],
                "common_count": 5,
                "e2e_cluster_count": 1,
            },
            {
                "times": [99, 16297, 9528533],
                "common_count": 1,
                "e2e_cluster_count": 1,
            },
        ],
    },
    {
        "commit": "449b9314e0f985044b5f9741dd847a670992c39d",
        "results": [
            {
                "times": [923190, 48323, 41729434],
                "common_count": 1,
                "e2e_cluster_count": 1,
            },
            {
                "times": [436906, 48613, 21500641],
                "common_count": 2,
                "e2e_cluster_count": 1,
            },
            {
                "times": [366107, 53043, 18508151],
                "common_count": 3,
                "e2e_cluster_count": 1,
            },
            {
                "times": [215320, 50998, 12127421],
                "common_count": 4,
                "e2e_cluster_count": 1,
            },
            {
                "times": [172936, 52352, 10332846],
                "common_count": 5,
                "e2e_cluster_count": 1,
            },
            {
                "times": [105, 16142, 9550154],
                "common_count": 1,
                "e2e_cluster_count": 1,
            },
        ],
    },
    {
        "commit": "2e94d9010bc88163150348ffe87ee62224c0e510",
        "results": [
            {
                "times": [3025380, 101404, 88239479],
                "common_count": 1,
                "e2e_cluster_count": 1,
            },
            {
                "times": [1555330, 104174, 45617043],
                "common_count": 2,
                "e2e_cluster_count": 1,
            },
            {
                "times": [902944, 99834, 29137662],
                "common_count": 3,
                "e2e_cluster_count": 1,
            },
            {
                "times": [720968, 104115, 22927229],
                "common_count": 4,
                "e2e_cluster_count": 1,
            },
            {
                "times": [567772, 106630, 18790857],
                "common_count": 5,
                "e2e_cluster_count": 1,
            },
            {
                "times": [99, 16115, 9631159],
                "common_count": 1,
                "e2e_cluster_count": 1,
            },
        ],
    },
    {
        "commit": "9bdbdaa89a7a29bc31dc55bc62ab7d0c64a5ce75",
        "results": [
            {
                "times": [11584, 13044, 7816170],
                "common_count": 1,
                "e2e_cluster_count": 1,
            },
            {
                "times": [4025, 13442, 8238002],
                "common_count": 2,
                "e2e_cluster_count": 1,
            },
            {
                "times": [2507, 13433, 7569132],
                "common_count": 3,
                "e2e_cluster_count": 1,
            },
            {
                "times": [1172, 13460, 7606235],
                "common_count": 4,
                "e2e_cluster_count": 1,
            },
            {
                "times": [99, 13229, 8065877],
                "common_count": 5,
                "e2e_cluster_count": 1,
            },
            {
                "times": [95, 15976, 9592182],
                "common_count": 1,
                "e2e_cluster_count": 1,
            },
        ],
    },
]

if __name__ == '__main__':
    main()
