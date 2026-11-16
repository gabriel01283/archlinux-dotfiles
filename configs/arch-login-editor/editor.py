#!/usr/bin/env python3

import configparser
import shutil
import subprocess
import sys
from pathlib import Path

from PySide6.QtCore import Qt
from PySide6.QtGui import QColor, QPixmap
from PySide6.QtWidgets import (
    QApplication, QWidget, QVBoxLayout, QHBoxLayout, QComboBox,
    QLabel, QLineEdit, QPushButton, QSpinBox,
    QColorDialog, QFormLayout, QMessageBox, QGroupBox,
    QScrollArea, QFileDialog, QFrame, QStackedWidget, QGraphicsDropShadowEffect
)

THEME = Path.home() / ".local/share/sddm/themes/arch-login"
CONFIG = THEME / "theme.conf"

DEFAULTS = {
    "title": "ARCH LINUX",
    "username": "gabriel",
    "backgroundColor": "#071522",
    "panelColor": "#10314A",
    "accentColor": "#00F5FF",
    "textColor": "#D9F5FF",
    "panelWidth": "420",
    "panelOffsetX": "0",
    "panelOffsetY": "0",
    "backgroundImage": "",
}



class SafeSpinBox(QSpinBox):
    def wheelEvent(self, event):
        event.ignore()


class SafeComboBox(QComboBox):
    def wheelEvent(self, event):
        event.ignore()


class LoginEditor(QWidget):
    def __init__(self):
        super().__init__()

        self.setWindowTitle("Configurações — Tela de Login")
        self.resize(1120, 760)
        self.setMinimumSize(850, 590)

        self.setObjectName("window")
        self.setStyleSheet("""
            QWidget#window { background: #050D18; color: #E5F8FF; }
            QWidget { color: #E5F8FF; font-family: 'Noto Sans', sans-serif; font-size: 13px; }
            QFrame#sidebar { background: #091827; border-right: 1px solid #16354A; }
            QFrame#surface { background: #0B1D2D; border: 1px solid #1B3A4E; border-radius: 16px; }
            QFrame#previewSurface { background: #081724; border: 1px solid #1B3A4E; border-radius: 18px; }
            QLabel#eyebrow { color: #36D9F3; font-size: 11px; font-weight: 700; }
            QLabel#headline { font-size: 25px; font-weight: 700; }
            QLabel#muted { color: #86A9BC; }
            QLabel#sectionTitle { font-size: 15px; font-weight: 700; }
            QLineEdit, QSpinBox, QComboBox {
                background: #071522; border: 1px solid #24465A;
                border-radius: 9px; padding: 8px 12px; min-height: 29px;
                selection-background-color: #007F98;
            }
            QLineEdit:focus, QSpinBox:focus, QComboBox:focus { border-color: #2CDDF4; }
            QPushButton {
                background: #102B3D; border: 1px solid #23475B;
                border-radius: 10px; padding: 9px 14px; min-height: 24px;
            }
            QPushButton:hover { background: #174157; border-color: #36D9F3; }
            QPushButton#nav { text-align: left; background: transparent; border: 0;
                color: #92B1C1; padding: 13px 17px; font-weight: 600; }
            QPushButton#nav:hover { background: #112B3B; color: #E5F8FF; }
            QPushButton#nav:checked { background: #12384A; color: #59EAFF;
                border-left: 3px solid #30E2FA; border-radius: 7px; }
            QPushButton#primary { background: #00CBE7; color: #03141E;
                border-color: #00CBE7; font-weight: 800; }
            QPushButton#primary:hover { background: #67EFFF; }
            QGroupBox { background: #0B1D2D; border: 1px solid #1B3A4E;
                border-radius: 15px; margin-top: 18px; padding: 18px 16px 15px;
                font-weight: 700; font-size: 14px; }
            QGroupBox::title { subcontrol-origin: margin; left: 18px; top: 0px;
                padding: 0 8px; color: #B6F4FF; }
            QScrollArea { border: none; background: transparent; }
            QScrollArea > QWidget > QWidget { background: transparent; }
            QScrollBar:vertical { background: transparent; width: 7px; margin: 0; }
            QScrollBar::handle:vertical { background: #28536A; border-radius: 3px; min-height: 30px; }
            QScrollBar::add-line:vertical, QScrollBar::sub-line:vertical { height: 0; }
            QScrollBar::add-page:vertical, QScrollBar::sub-page:vertical { background: transparent; }
        """)

        self.fields = {}
        self.load_values()
        self.pending_wallpaper = None
        self.build_ui()

    def load_values(self):
        parser = configparser.ConfigParser(interpolation=None)
        parser.optionxform = str
        parser.read(CONFIG)

        self.values = DEFAULTS.copy()

        if parser.has_section("General"):
            for key in DEFAULTS:
                if parser.has_option("General", key):
                    self.values[key] = parser.get("General", key)

    def build_ui(self):
        root = QHBoxLayout(self)
        root.setContentsMargins(0, 0, 0, 0)
        root.setSpacing(0)

        sidebar = QFrame()
        sidebar.setObjectName("sidebar")
        sidebar.setFixedWidth(232)
        side = QVBoxLayout(sidebar)
        side.setContentsMargins(17, 28, 17, 24)
        side.setSpacing(9)
        brand = QLabel("◈  OCEAN NEON")
        brand.setStyleSheet("color: #55E9FF; font-size: 16px; font-weight: 800;")
        side.addWidget(brand)
        hint = QLabel("CENTRAL DE APARÊNCIA")
        hint.setObjectName("eyebrow")
        side.addWidget(hint)
        side.addSpacing(35)
        self.desktop_button = QPushButton("▧   Tela principal")
        self.login_button = QPushButton("◉   Tela de login")
        for button in (self.desktop_button, self.login_button):
            button.setObjectName("nav")
            button.setCheckable(True)
            side.addWidget(button)
        self.login_button.setChecked(True)
        self.desktop_button.clicked.connect(self.open_desktop_settings)
        self.login_button.clicked.connect(self.select_login_settings)
        side.addStretch()
        back = QPushButton("←  Voltar às configurações")
        back.setObjectName("nav")
        back.clicked.connect(self.back_to_settings)
        side.addWidget(back)
        root.addWidget(sidebar)

        main = QWidget()
        main_layout = QVBoxLayout(main)
        main_layout.setContentsMargins(28, 27, 28, 22)
        main_layout.setSpacing(16)
        eyebrow = QLabel("PERSONALIZAÇÃO / ARCH LINUX")
        eyebrow.setObjectName("eyebrow")
        main_layout.addWidget(eyebrow)
        self.page_title = QLabel("Tela de login")
        self.page_title.setObjectName("headline")
        main_layout.addWidget(self.page_title)
        self.page_subtitle = QLabel("Configure sua identidade, cores e plano de fundo.")
        self.page_subtitle.setObjectName("muted")
        main_layout.addWidget(self.page_subtitle)

        self.pages = QStackedWidget()
        main_layout.addWidget(self.pages, 1)

        def make_page():
            scroll = QScrollArea()
            scroll.setWidgetResizable(True)
            scroll.setHorizontalScrollBarPolicy(Qt.ScrollBarPolicy.ScrollBarAlwaysOff)
            panel = QWidget()
            layout = QVBoxLayout(panel)
            layout.setContentsMargins(1, 12, 10, 12)
            layout.setSpacing(17)
            layout.setAlignment(Qt.AlignmentFlag.AlignTop)
            scroll.setWidget(panel)
            return scroll, layout

        self.login_scroll, login = make_page()
        self.desktop_scroll, desktop = make_page()
        self.pages.addWidget(self.login_scroll)
        self.pages.addWidget(self.desktop_scroll)

        general = QGroupBox("Identidade")
        general.setMinimumWidth(430)
        general_form = QFormLayout(general)
        general_form.setSpacing(8)
        for key, label in (("title", "Título"), ("username", "Usuário")):
            field = QLineEdit(self.values[key])
            field.setMinimumWidth(230)
            self.fields[key] = field
            general_form.addRow(label, field)
        login.addWidget(general)

        colors = QGroupBox("Cores")
        colors.setMinimumWidth(430)
        colors_form = QFormLayout(colors)
        colors_form.setSpacing(8)
        for key, label in (
            ("backgroundColor", "Fundo"), ("panelColor", "Painel"),
            ("accentColor", "Destaque"), ("textColor", "Texto")
        ):
            button = QPushButton(self.values[key])
            button.setMinimumWidth(160)
            button.clicked.connect(lambda checked=False, k=key: self.pick_color(k))
            self.fields[key] = button
            colors_form.addRow(label, button)
            self.update_color_swatch(key)
        login.addWidget(colors)

        position = QGroupBox("Posicionamento")
        position.setMinimumWidth(430)
        position_form = QFormLayout(position)
        position_form.setSpacing(8)
        for key, label, minimum, maximum in (
            ("panelWidth", "Largura", 300, 900),
            ("panelOffsetX", "Horizontal", -1500, 1500),
            ("panelOffsetY", "Vertical", -900, 900)
        ):
            field = SafeSpinBox()
            field.setFixedSize(140, 34)
            field.setAlignment(Qt.AlignmentFlag.AlignCenter)
            field.setRange(minimum, maximum)
            field.setValue(int(self.values[key]))
            self.fields[key] = field
            position_form.addRow(label, field)
        login.addWidget(position)

        wallpaper = QGroupBox("Wallpaper do login")
        wallpaper.setMinimumWidth(430)
        wallpaper_layout = QVBoxLayout(wallpaper)
        wallpaper_layout.setSpacing(8)
        self.wallpaper_label = QLabel(
            self.values.get("backgroundImage", "") or "Nenhuma imagem selecionada"
        )
        self.wallpaper_label.setWordWrap(True)
        self.wallpaper_label.setStyleSheet("color: #93BDD0;")
        wallpaper_layout.addWidget(self.wallpaper_label)
        self.wallpaper_preview = QLabel()
        self.wallpaper_preview.setMinimumHeight(190)
        self.wallpaper_preview.setAlignment(Qt.AlignmentFlag.AlignCenter)
        self.wallpaper_preview.setStyleSheet(
            "background: #071522; border: 1px solid #167CA6; border-radius: 8px;"
        )
        wallpaper_layout.addWidget(self.wallpaper_preview)
        self.update_wallpaper_preview(self.values.get("backgroundImage", ""))
        wallpaper_actions = QHBoxLayout()
        choose = QPushButton("Escolher imagem")
        choose.clicked.connect(self.choose_wallpaper)
        remove = QPushButton("Remover imagem")
        remove.clicked.connect(self.remove_wallpaper)
        for button in (choose, remove):
            button.setFixedWidth(160)
            wallpaper_actions.addWidget(button)
        wallpaper_actions.addStretch()
        wallpaper_layout.addLayout(wallpaper_actions)
        login.addWidget(wallpaper)

        desktop_group = QGroupBox("Wallpaper da tela principal")
        desktop_group.setMinimumWidth(430)
        desktop_layout = QVBoxLayout(desktop_group)
        desktop_layout.setSpacing(10)
        description = QLabel("Selecione o monitor e escolha uma imagem.")
        description.setStyleSheet("color: #93BDD0;")
        desktop_layout.addWidget(description)
        self.monitor_selector = SafeComboBox()
        self.monitor_selector.addItems([
            "Ambos os monitores", "Notebook (eDP-1)", "LG UltraGear (HDMI-A-1)"
        ])
        self.monitor_selector.setFixedWidth(280)
        self.monitor_selector.currentIndexChanged.connect(self.load_desktop_wallpaper)
        desktop_layout.addWidget(self.monitor_selector)
        self.desktop_wallpaper_path = ""
        self.desktop_wallpaper_preview = QLabel("Nenhum wallpaper selecionado")
        self.desktop_wallpaper_preview.setAlignment(Qt.AlignmentFlag.AlignCenter)
        self.desktop_wallpaper_preview.setMinimumHeight(240)
        self.desktop_wallpaper_preview.setStyleSheet(
            "background: #071522; border: 1px solid #167CA6; border-radius: 8px;"
        )
        desktop_layout.addWidget(self.desktop_wallpaper_preview)
        self.load_desktop_wallpaper()
        choose_desktop = QPushButton("Escolher wallpaper")
        choose_desktop.setFixedWidth(180)
        choose_desktop.clicked.connect(self.choose_desktop_wallpaper)
        desktop_layout.addWidget(choose_desktop)
        desktop.addWidget(desktop_group)

        footer = QHBoxLayout()
        footer.setSpacing(8)
        footer.addStretch()
        self.save_button = QPushButton("Salvar")
        self.preview_button = QPushButton("Pré-visualizar")
        self.restore_button = QPushButton("Restaurar padrões")
        for button, callback in (
            (self.save_button, self.save),
            (self.preview_button, self.preview),
            (self.restore_button, self.restore)
        ):
            button.setFixedWidth(150)
            button.clicked.connect(callback)
            footer.addWidget(button)
        self.save_button.setObjectName("primary")
        main_layout.addLayout(footer)
        root.addWidget(main, 1)

    def update_wallpaper_preview(self, filename):
        if filename.startswith("file://"):
            from PySide6.QtCore import QUrl
            filename = QUrl(filename).toLocalFile()

        pixmap = QPixmap(filename)

        if pixmap.isNull():
            self.wallpaper_preview.setPixmap(QPixmap())
            self.wallpaper_preview.setText("Sem imagem")
            return

        self.wallpaper_preview.setText("")
        self.wallpaper_preview.setPixmap(
            pixmap.scaled(
                420, 160,
                Qt.AspectRatioMode.KeepAspectRatio,
                Qt.TransformationMode.SmoothTransformation
            )
        )

    def choose_wallpaper(self):
        filename, _ = QFileDialog.getOpenFileName(
            self,
            "Escolher wallpaper",
            str(Path.home() / "Imagens/Wallpapers"),
            "Imagens (*.png *.jpg *.jpeg *.webp)"
        )

        if filename:
            self.pending_wallpaper = filename
            self.wallpaper_label.setText(filename)
            self.update_wallpaper_preview(filename)

    def remove_wallpaper(self):
        self.pending_wallpaper = ""
        self.wallpaper_label.setText("Nenhuma imagem selecionada")
        self.update_wallpaper_preview("")

    def choose_desktop_wallpaper(self):
        filename, _ = QFileDialog.getOpenFileName(
            self,
            "Escolher wallpaper da tela principal",
            str(Path.home() / "Imagens/Wallpapers"),
            "Imagens (*.png *.jpg *.jpeg *.webp)"
        )

        if not filename:
            return

        pixmap = QPixmap(filename)

        if pixmap.isNull():
            QMessageBox.warning(
                self, "Imagem inválida",
                "Não foi possível carregar a imagem selecionada."
            )
            return

        self.desktop_wallpaper_path = filename
        self.desktop_wallpaper_preview.setText("")
        self.desktop_wallpaper_preview.setPixmap(
            pixmap.scaled(
                420, 190,
                Qt.AspectRatioMode.KeepAspectRatio,
                Qt.TransformationMode.SmoothTransformation
            )
        )

    def back_to_settings(self):
        subprocess.Popen([
            "bash",
            str(
                Path.home()
                / ".config/waybar/scripts/configuracoes.sh"
            )
        ])
        self.close()

    def load_desktop_wallpaper(self):
        state = Path.home() / ".config/hypr/wallpapers"

        def saved(name):
            file = state / name
            if not file.is_file():
                return ""
            return file.read_text().strip()

        notebook = saved("notebook")
        lg = saved("lg")

        selection = self.monitor_selector.currentIndex()

        if selection == 1:
            wallpaper = notebook
        elif selection == 2:
            wallpaper = lg
        elif notebook == lg:
            wallpaper = notebook
        else:
            wallpaper = ""

        self.desktop_wallpaper_path = wallpaper

        if wallpaper and Path(wallpaper).is_file():
            pixmap = QPixmap(wallpaper)

            if not pixmap.isNull():
                self.desktop_wallpaper_preview.setText("")
                self.desktop_wallpaper_preview.setPixmap(
                    pixmap.scaled(
                        420, 190,
                        Qt.AspectRatioMode.KeepAspectRatio,
                        Qt.TransformationMode.SmoothTransformation
                    )
                )
                return

        self.desktop_wallpaper_preview.clear()

        if selection == 0 and notebook != lg:
            self.desktop_wallpaper_preview.setText(
                "Os monitores possuem wallpapers diferentes. "
                "Selecione um monitor para visualizar."
            )
        else:
            self.desktop_wallpaper_preview.setText(
                "Nenhum wallpaper selecionado"
            )

    def open_desktop_settings(self):
        self.desktop_button.setChecked(True)
        self.login_button.setChecked(False)
        self.pages.setCurrentWidget(self.desktop_scroll)
        self.page_title.setText("Tela principal")
        self.page_subtitle.setText(
            "Personalize o wallpaper do Hyprland."
        )

    def select_login_settings(self):
        self.desktop_button.setChecked(False)
        self.login_button.setChecked(True)
        self.pages.setCurrentWidget(self.login_scroll)
        self.page_title.setText("Tela de Login")
        self.page_subtitle.setText(
            "Personalize a aparência do Arch Login."
        )

    def update_color_swatch(self, key):
        button = self.fields[key]
        color = QColor(button.text())
        if color.isValid():
            button.setStyleSheet(
                "QPushButton { text-align: left; padding-left: 16px; "
                f"border-left: 6px solid {color.name()}; }}"
            )

    def pick_color(self, key):
        current = QColor(self.fields[key].text())
        color = QColorDialog.getColor(current, self, "Escolher cor")

        if color.isValid():
            self.fields[key].setText(color.name())
            self.update_color_swatch(key)

    def preview_desktop(self):
        if not self.desktop_wallpaper_path:
            QMessageBox.information(
                self, "Pré-visualização",
                "Escolha um wallpaper primeiro."
            )
            return

        dialog = QMessageBox(self)
        dialog.setWindowTitle("Wallpaper selecionado")
        dialog.setText(self.desktop_wallpaper_path)
        dialog.setIconPixmap(
            QPixmap(self.desktop_wallpaper_path).scaled(
                640, 360,
                Qt.AspectRatioMode.KeepAspectRatio,
                Qt.TransformationMode.SmoothTransformation
            )
        )
        dialog.exec()

    def save_desktop(self):
        image = Path(self.desktop_wallpaper_path)

        if not image.is_file():
            QMessageBox.warning(
                self, "Wallpaper",
                "Escolha uma imagem válida antes de salvar."
            )
            return

        state = Path.home() / ".config/hypr/wallpapers"
        config = Path.home() / ".config/hypr/hyprpaper.conf"
        state.mkdir(parents=True, exist_ok=True)

        notebook_file = state / "notebook"
        lg_file = state / "lg"

        notebook = (
            notebook_file.read_text().strip()
            if notebook_file.exists() else ""
        )
        lg = (
            lg_file.read_text().strip()
            if lg_file.exists() else ""
        )

        selection = self.monitor_selector.currentIndex()

        if selection in (0, 1):
            notebook = str(image.resolve())

        if selection in (0, 2):
            lg = str(image.resolve())

        lines = ["splash = false", ""]

        for monitor, wallpaper in (
            ("eDP-1", notebook),
            ("HDMI-A-1", lg),
        ):
            if wallpaper and Path(wallpaper).is_file():
                lines.extend([
                    "wallpaper {",
                    f"    monitor = {monitor}",
                    f"    path = {wallpaper}",
                    "    fit_mode = cover",
                    "}",
                    "",
                ])

        try:
            import os
            import tempfile
            import shutil

            with tempfile.NamedTemporaryFile(
                mode="w",
                dir=str(config.parent),
                delete=False,
                encoding="utf-8"
            ) as temp:
                temp.write("\n".join(lines))
                temporary = Path(temp.name)

            if config.exists():
                shutil.copy2(config, config.with_suffix(".conf.bak"))

            os.replace(temporary, config)

            notebook_file.write_text(notebook)
            lg_file.write_text(lg)

            subprocess.run(
                ["pkill", "-x", "hyprpaper"],
                check=False
            )

            subprocess.Popen(
                ["hyprpaper"],
                stdout=subprocess.DEVNULL,
                stderr=subprocess.DEVNULL,
                stdin=subprocess.DEVNULL,
                start_new_session=True
            )

        except Exception as exc:
            QMessageBox.critical(
                self, "Erro",
                f"Não foi possível aplicar o wallpaper:\\n{exc}"
            )
            return

        QMessageBox.information(
            self, "Wallpaper",
            "Wallpaper aplicado à tela principal."
        )

    def save(self):
        if self.desktop_button.isChecked():
            self.save_desktop()
            return

        values = {}

        for key, widget in self.fields.items():
            if isinstance(widget, QSpinBox):
                values[key] = str(widget.value())
            elif isinstance(widget, QPushButton):
                values[key] = widget.text()
            else:
                values[key] = widget.text()

        if not values["username"].strip():
            QMessageBox.warning(
                self, "Usuário inválido",
                "O nome do usuário não pode ficar vazio."
            )
            return

        for key in (
            "backgroundColor", "panelColor",
            "accentColor", "textColor"
        ):
            if not QColor(values[key]).isValid():
                QMessageBox.warning(
                    self, "Cor inválida",
                    f"A cor {key} é inválida."
                )
                return

        if self.pending_wallpaper is not None:
            if self.pending_wallpaper:
                source = Path(self.pending_wallpaper)
                destination = THEME / ("wallpaper" + source.suffix.lower())

                try:
                    shutil.copy2(source, destination)
                except OSError as exc:
                    QMessageBox.critical(
                        self, "Erro ao copiar wallpaper", str(exc)
                    )
                    return

                values["backgroundImage"] = destination.as_uri()
            else:
                values["backgroundImage"] = ""
        else:
            values["backgroundImage"] = self.values.get(
                "backgroundImage", ""
            )

        parser = configparser.ConfigParser(interpolation=None)
        parser.optionxform = str
        parser["General"] = values

        with CONFIG.open("w") as file:
            parser.write(file)

        self.values = values.copy()
        self.pending_wallpaper = None

        QMessageBox.information(
            self, "Configuração salva",
            "As alterações foram salvas.\n"
            "Use Pré-visualizar para conferir o resultado."
        )

    def preview(self):
        if self.desktop_button.isChecked():
            self.preview_desktop()
            return

        subprocess.Popen([
            "sddm-greeter-qt6",
            "--test-mode",
            "--theme",
            str(THEME),
        ])

    def restore(self):
        if self.desktop_button.isChecked():
            self.load_desktop_wallpaper()
            return

        for key, widget in self.fields.items():
            value = DEFAULTS[key]

            if isinstance(widget, QSpinBox):
                widget.setValue(int(value))
            else:
                widget.setText(value)
                if key in ("backgroundColor", "panelColor", "accentColor", "textColor"):
                    self.update_color_swatch(key)
        self.pending_wallpaper = None
        self.wallpaper_label.setText(DEFAULTS["backgroundImage"] or "Nenhuma imagem selecionada")
        self.update_wallpaper_preview("")


app = QApplication(sys.argv)
window = LoginEditor()
window.show()
sys.exit(app.exec())
