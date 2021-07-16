import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:image_picker/image_picker.dart' as picker;

class FlutterImagePicker extends StatefulWidget {
  const FlutterImagePicker({
    this.onSelectImage,
    this.label,
    this.aspectRatio = 1,
    required this.controller,
  });

  ///função de callback quando uma imagem é selecionada, o parâmetro [imageBytes] contem os bytes da imagem.
  final Function(Uint8List imageBytes)? onSelectImage;

  ///mensagem exibida no botão
  final String? label;

  ///o aspecto da exibição da imagem, ainda não é possível recortar a imagem no aspecto informado, portanto as dimensões da imagem serão originais, para o aspecto 16x9, utilize [16/9].
  final double aspectRatio;

  ///o controller responsável por armazenar o estado e efetuar as validações.
  final FlutterImagePickerController controller;
  @override
  _FlutterImagePickerState createState() => _FlutterImagePickerState();
}

class _FlutterImagePickerState extends State<FlutterImagePicker> {
  Future<void> pickImage() async {
    final imagemSelected = await picker.ImagePicker().getImage(source: picker.ImageSource.gallery);
    if (imagemSelected != null) {
      final bytes = await imagemSelected.readAsBytes();
      widget.controller.imagePickedBytes = bytes;
      widget.controller.validate();
      if (widget.onSelectImage != null) {
        widget.onSelectImage!(bytes);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      child: ValueListenableBuilder<bool>(
        valueListenable: widget.controller.displayErrorNotifier,
        builder: (context, displayError, _) {
          return Column(
            children: [
              TextButton(
                style: ButtonStyle(
                  shape: MaterialStateProperty.all(
                    RoundedRectangleBorder(
                      side: BorderSide(
                        color: displayError ? Theme.of(context).errorColor : Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                      ),
                    ),
                  ),
                ),
                onPressed: pickImage,
                child: AspectRatio(
                  aspectRatio: widget.aspectRatio,
                  child: Container(
                    height: double.maxFinite,
                    width: double.maxFinite,
                    child: ValueListenableBuilder<Uint8List?>(
                      valueListenable: widget.controller.imagePickedBytesNotifier,
                      builder: (context, bytes, _) {
                        return Stack(
                          children: [
                            Positioned(
                              top: 0,
                              left: 0,
                              right: 0,
                              bottom: 0,
                              child: bytes != null
                                  ? Image.memory(
                                      bytes,
                                      fit: BoxFit.cover,
                                    )
                                  : Center(
                                      child: Text(widget.label ?? 'Escolha uma imagem.'),
                                    ),
                            ),
                            if (bytes != null)
                              Positioned(
                                top: 0,
                                right: 0,
                                child: IconButton(
                                  splashRadius: 20,
                                  onPressed: () {
                                    widget.controller.imagePickedBytes = null;
                                  },
                                  icon: Icon(Icons.close),
                                ),
                              ),
                          ],
                        );
                      },
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: 20,
                child: Text(
                  displayError ? widget.controller.requiredErrorMessage : '',
                  style: TextStyle(
                    color: Theme.of(context).errorColor,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class FlutterImagePickerController {
  FlutterImagePickerController({this.required = false, this.requiredErrorMessage = 'Selecione uma imagem.'});

  ///value notifier dos bytes da imagem seleciona podendo ser utilizado em um ValueListenableBuilder.
  final imagePickedBytesNotifier = ValueNotifier<Uint8List?>(null);

  ///value notifier do status de erro podendo ser utilizado em um ValueListenableBuilder.
  final displayErrorNotifier = ValueNotifier<bool>(false);

  ///mensagem apresentada caso a validação não seja bem sucedida.
  final String requiredErrorMessage;

  ///caso seja true, a validação apresentará a mensagem de erro definida em [requiredErrorMessage].
  final bool required;

  ///retorna os bytes da imagem selecionada ou nulo caso nenhuma esteja selecionada.
  Uint8List? get imagePickedBytes => imagePickedBytesNotifier.value;

  ///define os bytes da imagem selecionada ou null para limpar a imagem selecionada.
  set imagePickedBytes(Uint8List? newImage) => imagePickedBytesNotifier.value = newImage;

  ///valida o campo se for obrigatorio;
  bool validate() {
    if (required && imagePickedBytes == null) {
      displayErrorNotifier.value = true;
      return false;
    } else {
      displayErrorNotifier.value = false;
      return true;
    }
  }
}
